require 'forwardable'
require 'active_graph/version'

require 'active_graph/core'
require 'active_graph/core/query_ext' # From this gem

require 'active_support/core_ext/module/attribute_accessors_per_thread'
require 'active_graph/secure_random_ext'
require 'active_graph/transactions'
require 'active_graph/base'
require 'active_graph/model_schema'

require 'active_model'
require 'active_support/concern'
require 'active_support/core_ext/class/attribute.rb'
require 'active_support/core_ext/class/subclasses.rb'
require 'active_support/core_ext/module/attribute_accessors'
require 'json'

require 'active_graph/lazy_attribute_hash'
require 'active_graph/attribute_set'
require 'active_graph/errors'
require 'active_graph/config'
require 'active_graph/wrapper'
require 'active_graph/relationship/rel_wrapper'
require 'active_graph/node/node_wrapper'
require 'active_graph/shared/type_converters'
require 'active_graph/shared/rel_type_converters'
require 'active_graph/shared/marshal'
require 'active_graph/type_converters'
require 'active_graph/paginated'
require 'active_graph/schema/operation'

require 'active_graph/timestamps'
require 'active_graph/undeclared_properties'

require 'active_graph/shared/callbacks'
require 'active_graph/shared/filtered_hash'
require 'active_graph/shared/declared_property/index'
require 'active_graph/shared/declared_property'
require 'active_graph/shared/declared_properties'
require 'active_graph/shared/enum'
require 'active_graph/shared/mass_assignment'
require 'active_graph/shared/attributes'
require 'active_graph/shared/typecasted_attributes'
require 'active_graph/shared/property'
require 'active_graph/shared/persistence'
require 'active_graph/shared/validations'
require 'active_graph/shared/identity'
require 'active_graph/shared/serialized_properties'
require 'active_graph/shared/typecaster'
require 'active_graph/shared/initialize'
require 'active_graph/shared/query_factory'
require 'active_graph/shared/cypher'
require 'active_graph/shared/permitted_attributes'
require 'active_graph/shared'

require 'active_graph/relationship/callbacks'
require 'active_graph/relationship/initialize'
require 'active_graph/relationship/property'
require 'active_graph/relationship/persistence/query_factory'
require 'active_graph/relationship/persistence'
require 'active_graph/relationship/validations'
require 'active_graph/relationship/query'
require 'active_graph/relationship/related_node'
require 'active_graph/relationship/types'
require 'active_graph/relationship'

require 'active_graph/node/dependent_callbacks'
require 'active_graph/node/node_list_formatter'
require 'active_graph/node/dependent'
require 'active_graph/node/dependent/query_proxy_methods'
require 'active_graph/node/dependent/association_methods'
require 'active_graph/node/enum'
require 'active_graph/node/query_methods'
require 'active_graph/node/query/query_proxy_methods'
require 'active_graph/node/query/query_proxy_methods_of_mass_updating'
require 'active_graph/node/query/query_proxy_enumerable'
require 'active_graph/node/query/query_proxy_find_in_batches'
require 'active_graph/node/query/query_proxy_eager_loading'
require 'active_graph/node/query/query_proxy_eager_loading/association_tree'
require 'active_graph/node/query/query_proxy_link'
require 'active_graph/node/labels/index'
require 'active_graph/node/labels/reloading'
require 'active_graph/node/labels'
require 'active_graph/node/id_property/accessor'
require 'active_graph/node/id_property'
require 'active_graph/node/callbacks'
require 'active_graph/node/initialize'
require 'active_graph/node/property'
require 'active_graph/node/persistence'
require 'active_graph/node/validations'
require 'active_graph/node/rels'
require 'active_graph/node/reflection'
require 'active_graph/node/unpersisted'
require 'active_graph/node/has_n'
require 'active_graph/node/has_n/association_cypher_methods'
require 'active_graph/node/has_n/association/rel_wrapper'
require 'active_graph/node/has_n/association/rel_factory'
require 'active_graph/node/has_n/association'
require 'active_graph/node/query/query_proxy'
require 'active_graph/node/query'
require 'active_graph/node/scope'
require 'active_graph/node'

require 'active_support/concern'
require 'active_graph/core/cypher_error'
require 'active_graph/core/schema_errors'

module ActiveGraph
  extend ActiveSupport::Autoload
  autoload :Migrations
  autoload :Migration
end

load 'active_graph/tasks/migration.rake'

require 'active_graph/node/orm_adapter'
if defined?(Rails)
  require 'rails/generators'
  require 'rails/generators/active_graph_generator'
end

Neo4j::Driver::Transaction.prepend ActiveGraph::Transaction
SecureRandom.singleton_class.prepend ActiveGraph::SecureRandomExt
