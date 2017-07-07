module Neo4j
  module ActiveNode
    module Query
      module QueryProxyEagerLoading
        class IdentityMap < Hash
          def add(node)
            self[node.neo_id] ||= node
          end
        end

        class AssociationTree < Hash
          attr_accessor :model, :name, :association, :path

          def initialize(model, name = nil)
            super()
            self.model = name ? target_class(model, name) : model
            self.name = name
            self.association = name ? model.associations[name] : nil
          end

          def clone
            super.tap { |copy| copy.each { |key, value| copy[key] = value.clone } }
          end

          def add_association(spec)
            if spec.is_a?(Array)
              spec.each { |s| add_association(s) }
            elsif spec.is_a?(Hash)
              spec.each { |k, v| (self[k] ||= AssociationTree.new(model, k)).add_association(v) }
            else
              self[spec] ||= AssociationTree.new(model, spec)
            end
          end

          def paths(*prefix)
            values.flat_map { |v| [[*prefix, v]] + v.paths(*prefix, v) }
          end

          private

          def target_class(model, key)
            association = model.associations[key]
            fail "Invalid association: #{[*path, key].join('.')}" unless association
            model.associations[key].target_class
          end
        end

        def pluck_vars(node, rel)
          return super if with_associations_spec.size.zero?

          perform_query
        end

        def perform_query
          @_cache = IdentityMap.new
          query_from_association_spec
            .map do |record, eager_data|
            cache_and_init(record, with_associations_spec)
            eager_data.zip(with_associations_spec.paths.map(&:last)).each do |eager_records, element|
              eager_records.first.zip(eager_records.last).each do |eager_record|
                add_to_cache(*eager_record, element)
              end
            end

            record
          end
        end

        def with_associations(*spec)
          new_link.tap do |new_query_proxy|
            new_query_proxy.with_associations_spec = with_associations_spec.clone
            new_query_proxy.with_associations_spec.add_association(spec)
          end
        end

        def with_associations_spec
          @with_associations_spec ||= AssociationTree.new(model)
        end

        def with_associations_spec=(tree)
          @with_associations_spec = tree
        end

        private

        def add_to_cache(rel, node, element)
          direction = element.association.direction
          if rel.is_a?(Neo4j::ActiveRel)
            rel.instance_variable_set(direction == :in ? '@from_node' : '@to_node', node)
          end
          @_cache[direction == :out ? rel.start_node_neo_id : rel.end_node_neo_id]
            .association_proxy(element.name).add_to_cache(cache_and_init(node, element), rel)
        end

        def init_associations(node, element)
          element.keys.each { |key| node.association_proxy(key).init_cache }
        end

        def cache_and_init(node, element)
          @_cache.add(node).tap { |n| init_associations(n, element) }
        end

        def with_associations_return_clause(variables = path_names)
          variables.map { |n| escape("#{n}_collection") }.join(',')
        end

        def escape(s)
          s =~ /\./ ? "`#{s}`" : s
        end

        def path_name(path)
          path.map(&:name).join('.')
        end

        def path_names
          with_associations_spec.paths.map { |path| path_name(path) }
        end

        def query_from_association_spec
          previous_with_variables = []
          with_associations_spec.paths.inject(query_as(identity).with(identity)) do |query, path|
            with_association_query_part(query, path, previous_with_variables).tap do
              previous_with_variables << path_name(path)
            end
          end.pluck(identity, "[#{with_associations_return_clause}]")
        end

        def with_association_query_part(base_query, path, previous_with_variables)
          optional_match_with_where(base_query, path)
            .with(identity,
                  "[collect(#{escape("#{path_name(path)}_rel")}), collect(#{escape path_name(path)})] AS #{escape("#{path_name(path)}_collection")}",
                  *with_associations_return_clause(previous_with_variables))
        end

        def optional_match_with_where(base_query, path)
          path
            .each_with_index.map { |_, index| path[0..index] }
            .inject(optional_match(base_query, path)) do |query, path_prefix|
            query.where(path_prefix.last.association.target_where_clause(escape(path_name(path_prefix))))
          end
        end

        def optional_match(base_query, path)
          base_query.optional_match(
            "(#{identity})#{path.each_with_index.map do |element, index|
              relationship_part(element.association, path_name(path[0..index]))
            end.join}")
        end

        def relationship_part(association, path_name)
          "#{association.arrow_cypher(escape("#{path_name}_rel"))}(#{escape(path_name)})"
        end
      end
    end
  end
end
