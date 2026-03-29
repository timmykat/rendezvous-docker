ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = {
  mysql2: ['--no-defaults', '--skip-add-drop-table', '--no-tablespaces']
}
