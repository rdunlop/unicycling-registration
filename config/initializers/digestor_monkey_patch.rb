module ActionView
  class Digestor
    class << self
      def tree(name, finder, partial = false, seen = {})
        logical_name = name.gsub(%r{/_}, "/")

        options = {}
        options[:formats] = [finder.rendered_format] if finder.rendered_format
        options[:formats].push(:html) if finder.rendered_format == :pdf # XXX THIS IS THE PATCH
        if template = finder.disable_cache { finder.find_all(logical_name, [], partial, [], options).first }
          finder.rendered_format ||= template.formats.first

          if node = seen[template.identifier] # handle cycles in the tree
            node
          else
            node = seen[template.identifier] = Node.create(name, logical_name, template, partial)

            deps = DependencyTracker.find_dependencies(name, template, finder.view_paths)
            deps.uniq { |n| n.gsub(%r{/_}, "/") }.each do |dep_file|
              node.children << tree(dep_file, finder, true, seen)
            end
            node
          end
        else
          logger.error "  '#{name}' file doesn't exist, so no dependencies"
          logger.error "  Couldn't find template for digesting: #{name}"
          seen[name] ||= Missing.new(name, logical_name, nil)
        end
      end
    end
  end
end

# https://github.com/rails/rails/issues/28503
unless Rails::VERSION::STRING == "5.1.4"
  raise "Check on Monkeypatch"
end
