# Task Master File Structure

## Core Files
- `.taskmaster/tasks/tasks.json` - Main task database (never edit manually)
- `.taskmaster/docs/prd.txt` - Product Requirements Document
- `.taskmaster/config.json` - AI model configuration
- `.taskmaster/tasks/*.md` - Individual task files (auto-generated)
- `.taskmaster/state.json` - Tagged system state (current tag, migration status)
- `.taskmaster/reports/task-complexity-report.json` - Complexity analysis results

## Configuration Files
- `.taskmaster/config.json` - Main configuration:
  - AI model selections (main, research, fallback)
  - Parameters (max tokens, temperature)
  - Logging level
  - Default subtasks/priority
  - Project metadata
  - Tagged system settings (`global.defaultTag`, `tags` section)

## Environment Configuration
- **API Keys**: Stored in `.env` (CLI) or `.vscode/mcp.json` (MCP)
- **Required Keys**: ANTHROPIC_API_KEY, PERPLEXITY_API_KEY, OPENAI_API_KEY, GOOGLE_API_KEY, etc.
- **Note**: All non-API key settings managed via `task-master models` command

## PRD Best Practices
When creating PRD for TaskMaster:
1. Be specific about technical requirements
2. Include user stories with clear acceptance criteria
3. Specify technology constraints (Next.js 15+, HeroUI, etc.)
4. Define MVP scope vs future enhancements
5. Include performance and security requirements
6. Use `.taskmaster/templates/example_prd.txt` as reference

## Multi-Claude Workflows
For complex projects, use multiple Claude sessions:
```bash
# Terminal 1: Main implementation
cd project && claude

# Terminal 2: Testing and validation  
cd project && claude

# Terminal 3: Documentation updates
cd project && claude
```

## Task ID Format
- Main tasks: `1`, `2`, `3`, etc.
- Subtasks: `1.1`, `1.2`, `2.1`, etc.
- Reference in commits: `git commit -m "feat: implement auth (task 1.2)"`

## Research Mode
Always use `--research` flag for:
- Complex technical decisions
- Architecture planning
- Performance optimization strategies
- Security implementations
- Getting fresh information beyond knowledge cutoff

Example: `task-master expand --id=1 --research`

## Task Structure Fields
- **id**: Unique identifier (e.g., `1`, `1.1`)
- **title**: Brief descriptive title
- **description**: Concise summary of the task
- **status**: Current state (`pending`, `done`, `in-progress`, etc.)
- **dependencies**: Array of prerequisite task IDs
- **priority**: Importance level (`high`, `medium`, `low`)
- **details**: In-depth implementation instructions
- **testStrategy**: Verification approach
- **subtasks**: Array of smaller, specific tasks

## Tagged Task Lists System
- **Purpose**: Maintain separate task contexts for different features/branches
- **Default Tag**: "master" (automatic migration for existing projects)
- **Tag Naming**: Alphanumeric with hyphens/underscores
- **Context Isolation**: Tasks in different tags are completely separate
- **Common Patterns**:
  - Feature branches: `feature-user-auth`
  - Experiments: `experiment-new-state`
  - Version-based: `v2.0`, `mvp`
  - Team-based: `alice-work`, `bob-tasks`

## Rules Management
- **Location**: Various directories based on tool (`.github/instructions`, `.roo/rules`, etc.)
- **Available Profiles**: claude, cline, codex, cursor, roo, trae, windsurf
- **Management**: 
  - During init: `task-master init --rules vscode,windsurf`
  - After init: `task-master rules add/remove <profiles>`
  - Interactive: `task-master rules setup`