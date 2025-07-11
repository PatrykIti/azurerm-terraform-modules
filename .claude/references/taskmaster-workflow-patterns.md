# TaskMaster Workflow Patterns

## Standard Development Workflow

### Simple Workflow (Default Starting Point)
For new projects or when getting started, operate within the `master` tag context:

1. **Initialize**: `initialize_project` / `task-master init`
2. **Configure models**: `models` / `task-master models --setup`
3. **Create PRD**: Draft in `.taskmaster/docs/prd.txt`
4. **Parse PRD**: `parse_prd` / `task-master parse-prd`
5. **Analyze complexity**: `analyze_project_complexity` / `task-master analyze-complexity --research`
6. **Expand tasks**: `expand_all` / `task-master expand --all --research`
7. **Start work**: Follow the basic workflow loop

## Multi-Context Workflows with Tags

### When to Introduce Tags

#### Pattern 1: Simple Git Feature Branching
- **Trigger**: User creates new git branch
- **Action**: Propose tag mirroring branch name
- **Command**: `task-master add-tag --from-branch`

#### Pattern 2: Team Collaboration
- **Trigger**: User mentions working with teammates
- **Action**: Create separate tag for user's work
- **Command**: `task-master add-tag my-work --copy-from-current`

#### Pattern 3: Experiments or Risky Refactors
- **Trigger**: User wants to experiment
- **Action**: Create sandboxed tag
- **Command**: `task-master add-tag experiment-xyz --description="Testing new approach"`

#### Pattern 4: Large Feature Initiatives (PRD-Driven)
- **Trigger**: User describes significant multi-step feature
- **Action**: Create dedicated tag with PRD workflow
- **Process**:
  1. Create tag: `task-master add-tag feature-xyz`
  2. Draft PRD: `.taskmaster/docs/feature-xyz-prd.txt`
  3. Parse into tag: `task-master parse-prd prd.txt --tag=feature-xyz`
  4. Analyze & expand within tag

#### Pattern 5: Version-Based Development
- **Prototype/MVP Tags** (`prototype`, `mvp`, `v0.x`):
  - Focus on speed over perfection
  - Create simpler tasks with direct implementation
  - Lower complexity, fewer subtasks
  
- **Production/Mature Tags** (`v1.0+`, `production`):
  - Emphasize robustness and testing
  - Include comprehensive error handling
  - Higher complexity, detailed subtasks

## Iterative Subtask Implementation

### The Implementation Cycle
1. **Understand Goal**: `get_task` / `task-master show <subtaskId>`
2. **Initial Exploration**: Identify files, functions, line numbers
3. **Log the Plan**: `update_subtask` with detailed findings
4. **Verify Plan**: Re-read task to confirm plan was logged
5. **Begin Implementation**: `set_task_status --status=in-progress`
6. **Refine and Log Progress**:
   - What worked (fundamental truths)
   - What didn't work and why
   - Specific code snippets that succeeded
   - Decisions made with user input
   - Deviations from initial plan
7. **Review & Update Rules**: Identify patterns for rule files
8. **Mark Complete**: `set_task_status --status=done`
9. **Commit Changes**: Include task ID in commit message
10. **Next Task**: Use `next_task` to continue

## Implementation Drift Handling

Use when:
- Implementation differs from planned approach
- Future tasks need modification
- New dependencies emerge

Commands:
- Multiple tasks: `update --from=<id> --prompt="explanation"`
- Single task: `update_task --id=<id> --prompt="explanation"`

## Task Reorganization Patterns

### Common Move Scenarios
- **Task to subtask**: `move --from=5 --to=7.1`
- **Subtask to task**: `move --from=5.2 --to=10`
- **Subtask to different parent**: `move --from=5.2 --to=7.3`
- **Reorder subtasks**: `move --from=5.2 --to=5.4`
- **Multiple moves**: `move --from=10,11,12 --to=16,17,18`

### Merge Conflict Resolution
When team members create tasks on different branches:
1. Keep their tasks in place
2. Move your tasks to non-conflicting IDs
3. System creates placeholders for non-existent destinations

## Master List Strategy

Once using tags, master should contain only:
- **High-level deliverables** with significant business value
- **Major milestones** and epic-level features
- **Critical infrastructure** work
- **Release-blocking** items

NOT in master:
- Detailed implementation subtasks
- Refactoring work (use dedicated tags)
- Experimental features
- Team member-specific tasks

## Research Integration

Use the `research` tool frequently for:
- **Before implementing**: Current best practices
- **New technologies**: Up-to-date guidance
- **Security tasks**: Latest recommendations
- **Dependency updates**: Breaking changes
- **Performance optimization**: Current approaches
- **Debugging**: Known solutions

Pattern:
1. Use `research` to gather fresh information
2. Use `update_subtask` to commit findings
3. Use `update_task` to incorporate into task details
4. Use `add_task --research` for informed task creation