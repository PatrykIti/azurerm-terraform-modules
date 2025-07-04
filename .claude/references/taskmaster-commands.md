# TaskMaster Commands and Workflow

## Essential TaskMaster Commands
```bash
# Initial setup (only once per project)
task-master init
task-master parse-prd .taskmaster/docs/prd.txt

# Daily workflow
task-master next                          # Get next available task
task-master show <id>                     # View task details
task-master set-status --id=<id> --status=done

# Task management
task-master expand --id=<id> --research   # Break task into subtasks
task-master update-subtask --id=<id> --prompt="implementation notes"
task-master analyze-complexity --research # Analyze all tasks
```

## MCP Tools vs CLI Commands

### Initialization & Setup
- **MCP Tool**: `initialize_project`
- **CLI Command**: `task-master init [options]`
- **Key Options**: `--rules <profiles>` (claude, cline, codex, cursor, roo, trae, vscode, windsurf)

### Parse PRD
- **MCP Tool**: `parse_prd`
- **CLI Command**: `task-master parse-prd [file] [options]`
- **Key Options**: `--num-tasks <number>`, `--tag <name>`, `--research`

### AI Model Configuration
- **MCP Tool**: `models`
- **CLI Command**: `task-master models [options]`
- **Key Options**: `--set-main <model>`, `--set-research <model>`, `--set-fallback <model>`

### Task Management
- **Get Tasks**: `get_tasks` / `task-master list`
- **Next Task**: `next_task` / `task-master next`
- **Get Task**: `get_task` / `task-master show <id>`
- **Add Task**: `add_task` / `task-master add-task`
- **Update Task**: `update_task` / `task-master update-task`
- **Update Subtask**: `update_subtask` / `task-master update-subtask`
- **Set Status**: `set_task_status` / `task-master set-status`
- **Remove Task**: `remove_task` / `task-master remove-task`

### Task Structure & Breakdown
- **Expand Task**: `expand_task` / `task-master expand`
- **Expand All**: `expand_all` / `task-master expand --all`
- **Clear Subtasks**: `clear_subtasks` / `task-master clear-subtasks`
- **Remove Subtask**: `remove_subtask` / `task-master remove-subtask`
- **Move Task**: `move_task` / `task-master move`

### Dependency Management
- **Add Dependency**: `add_dependency` / `task-master add-dependency`
- **Remove Dependency**: `remove_dependency` / `task-master remove-dependency`
- **Validate Dependencies**: `validate_dependencies` / `task-master validate-dependencies`
- **Fix Dependencies**: `fix_dependencies` / `task-master fix-dependencies`

### Analysis & Reporting
- **Analyze Complexity**: `analyze_project_complexity` / `task-master analyze-complexity`
- **View Report**: `complexity_report` / `task-master complexity-report`

### AI-Powered Research
- **Research**: `research` / `task-master research`
- **Key Options**: `--save-to <id>`, `--tree`, `--files <paths>`, `--detail <level>`

### Tag Management
- **List Tags**: `list_tags` / `task-master tags`
- **Add Tag**: `add_tag` / `task-master add-tag <name>`
- **Delete Tag**: `delete_tag` / `task-master delete-tag <name>`
- **Use Tag**: `use_tag` / `task-master use-tag <name>`
- **Rename Tag**: `rename_tag` / `task-master rename-tag <old> <new>`
- **Copy Tag**: `copy_tag` / `task-master copy-tag <source> <target>`

## Task Status Values
- `pending` - Ready to work on
- `in-progress` - Currently being worked on
- `done` - Completed and verified
- `blocked` - Waiting on dependencies
- `deferred` - Postponed
- `cancelled` - No longer needed
- `review` - Ready for review

## Development Loop with TaskMaster
1. `task-master next` - Find next task
2. `task-master show <id>` - Review requirements
3. `task-master set-status --id=<id> --status=in-progress`
4. Implement the feature/fix
5. `task-master update-subtask --id=<id> --prompt="what worked/challenges"`
6. `task-master set-status --id=<id> --status=done`

## The Basic Workflow Loop
1. **`list`**: Show what needs to be done
2. **`next`**: Decide what to work on
3. **`show <id>`**: Get details for specific task
4. **`expand <id>`**: Break down complex tasks
5. **Implement**: Write code and tests
6. **`update-subtask`**: Log progress and findings
7. **`set-status`**: Mark tasks as done
8. **Repeat**

## Scrum Methodology Rules for TaskMaster
- **Epic Structure**: Group related tasks into epics (major features/components)
- **User Stories**: Write tasks as user stories where applicable ("As a... I want... So that...")
- **Story Points**: Estimate complexity using Fibonacci sequence (1, 2, 3, 5, 8, 13)
- **Sprint Planning**: Organize tasks into 2-week sprints based on velocity
- **Definition of Done**: Each task must have clear acceptance criteria
- **Task Hierarchy**: Epic → User Story → Task → Subtask
- **Priority Levels**: Use MoSCoW method (Must have, Should have, Could have, Won't have)
- **Daily Updates**: When updating tasks, include: What was done, What will be done, Any blockers

## Important Notes
- **AI Processing**: Tools like `parse_prd`, `analyze_project_complexity`, `expand_task`, `update_task`, and `research` make AI calls and can take up to a minute
- **MCP Priority**: Always prefer MCP tools over CLI when available (better performance, structured data, error handling)
- **API Keys**: Must be configured in `.env` (CLI) or `.vscode/mcp.json` (MCP)
- **Research Tool**: Use frequently for fresh information beyond knowledge cutoff
- **Tag System**: Tasks are organized into separate contexts (tags) for better organization