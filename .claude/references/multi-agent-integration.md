# Multi-Agent Integration with TaskMaster

## TaskMaster Multi-Agent Integration
```bash
# Assign tasks to specific agents
task-master update-task --id=1 --prompt="Assigned to Agent 2: Testing"
task-master add-subtask --id=1 --title="Agent 3: Update documentation"

# Track multi-agent progress
task-master show 1  # View all agent assignments
```

## Context7 + Gemini Zen Coordination
- Primary Claude consults MCP tools
- Shares findings with assigned agents
- Agents implement with provided context
- No direct MCP tool usage by secondary agents (to avoid conflicts)