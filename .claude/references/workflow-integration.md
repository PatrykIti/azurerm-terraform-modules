# Workflow Integration

## Standard Workflow
1. **Problem Identification** → Context7 MCP (documentation)
2. **Analysis & Validation** → Gemini Zen (with Context7 findings)
3. **Task Planning** → TaskMaster AI (after technical clarity)
4. **Implementation** → You (Claude) orchestrate based on all inputs

These tools are complementary - use them in sequence for maximum effectiveness.

## Workflow with Feedback Loops

### 1. Problem Identification → Context7 MCP
- Gather documentation and examples
- If insufficient, refine query and retry
- Default to Context7 for project-specific information
- ALWAYS prefer Context7 over web search for known technologies

### 2. Analysis & Validation → Gemini Zen
- Analyze with Context7 findings
- **Feedback**: If missing context, return to step 1
- Web search allowed for external/novel problems (new libraries, uncommon errors)
- CRITICALLY EVALUATE all suggestions - don't accept blindly

### 3. Task Planning → TaskMaster AI
- Break down validated approach
- **Feedback**: If reveals flaws, return to step 2
- Follow Scrum best practices
- Ensure tasks align with project constraints

### 4. Implementation → Claude orchestrates
- Execute based on all inputs
- Document decisions and rationale
- Apply critical thinking to all tool outputs
- Make final decisions based on project context

## Feedback Loop Scenarios

### Scenario 1: Analysis → Problem ID (Gemini Zen to Context7)
**Task**: "Improve performance of `process_large_file` function"
- **Step 1**: Context7 gathers source code
- **Step 2**: Gemini Zen discovers external microservice dependency
- **Feedback Trigger**: Insufficient context about external service
- **Action**: Return to Step 1 with refined request: "Find API contract and performance metrics for DataEnrichmentService"

### Scenario 2: Planning → Analysis (TaskMaster to Gemini Zen)
**Task**: "Implement user profile image uploads"
- **Step 2**: Gemini Zen proposes S3 + pre-signed URLs solution
- **Step 3**: TaskMaster identifies missing security/validation tasks
- **Feedback Trigger**: Flaw in validated approach
- **Action**: Return to Step 2: "Solution incomplete - add image validation and security requirements"

## Decision Authority
**ABSOLUTE RULE**: Claude is the orchestrator and final decision maker. 

Tools provide:
- Context7: Authoritative documentation (trust but verify)
- Gemini Zen: Analysis and alternatives (evaluate critically)
- TaskMaster: Structured planning (adjust to project needs)

But Claude:
- Synthesizes all inputs with critical thinking
- Questions everything - especially complex solutions
- Makes final implementation decisions
- Takes responsibility for choices
- Prioritizes project success over theoretical perfection

## TaskMaster Tag Integration

### When to Use Tags in Workflow
1. **Feature Development**: Create tag before Context7/Gemini analysis
2. **Experimentation**: Isolate risky changes in experimental tags
3. **Team Collaboration**: Separate contexts prevent conflicts
4. **Version Management**: Different approaches for MVP vs production

### Tag-Aware Workflow
1. **Identify Context**: Determine if new tag needed
2. **Create Tag**: `add_tag` with appropriate name
3. **Switch Context**: `use_tag` to work in isolation
4. **Follow Standard Workflow**: Within tag context
5. **Merge Back**: When feature complete

### PRD-Driven Tag Workflow
1. **Create Feature Tag**: `add_tag feature-xyz`
2. **Context7 Research**: Gather existing code patterns
3. **Gemini Analysis**: Validate approach with research
4. **Draft PRD**: Incorporate findings
5. **Parse into Tag**: `parse_prd --tag=feature-xyz`
6. **Implement**: Follow tasks within tag

## MCP vs CLI Decision Tree

### Use MCP Tools When:
- Working in VS Code or integrated environment
- Need structured data responses
- Performing batch operations
- Want better error handling
- Running from automation

### Use CLI When:
- Direct terminal interaction preferred
- MCP server unavailable
- Quick one-off commands
- Interactive workflows needed
- Debugging MCP issues

## Critical Rules for Tool Usage

1. **Context7 First**: Always check Context7 before web search
2. **Validate Everything**: Don't blindly follow tool suggestions
3. **Tag Isolation**: Keep experimental work in separate tags
4. **Research Frequently**: Use TaskMaster research for fresh info
5. **Document Decisions**: Log reasoning in subtask updates
6. **MCP Priority**: Prefer MCP tools over CLI when available
7. **API Key Check**: Verify keys in `.env` or `mcp.json`