# NOTE: only doing this in development as some production environments (Heroku)
# NOTE: are sensitive to local FS writes, and besides -- it's just not proper
# NOTE: to have a dev-mode tool do its thing in production.
if Rails.env.development?
  task :set_annotation_options do
    # You can override any of these by setting an environment variable of the
    # same name.
    Annotate.set_defaults('position_in_routes'   => "after",
                          'position_in_class'    => "before",
                          'position_in_test'     => "after",
                          'position_in_fixture'  => "after",
                          'position_in_factory'  => "after",
                          'show_indexes'         => "true",
                          'simple_indexes'       => "false",
                          'model_dir'            => "app/models",
                          'include_version'      => "false",
                          'require'              => "",
                          'exclude_tests'        => "false",
                          'exclude_fixtures'     => "true",
                          'exclude_factories'    => "false",
                          'ignore_model_sub_dir' => "false",
                          'skip_on_db_migrate'   => "false",
                          'format_bare'          => "true",
                          'format_rdoc'          => "false",
                          'format_markdown'      => "false",
                          'sort'                 => "false",
                          'force'                => "false",
                          'trace'                => "false",)
  end

  Annotate.load_tasks

  # Annotate models
  task :annotate do
    puts 'Annotating models...'
    system 'bundle exec annotate'
  end

  # Run annotate task after db:migrate
  #  and db:rollback tasks
  Rake::Task['db:migrate'].enhance do
    Rake::Task['annotate'].invoke
  end

  Rake::Task['db:rollback'].enhance do
    Rake::Task['annotate'].invoke
  end
end
