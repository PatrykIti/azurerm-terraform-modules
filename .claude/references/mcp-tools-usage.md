# MCP Tools Usage Rules (MANDATORY)

## Task Triage (FIRST STEP)
Before engaging the full workflow, assess task complexity:
- **Trivial tasks** (typos, simple fixes): Handle directly or single consultation
- **Complex tasks/features**: Engage full workflow starting with Context7 MCP
- **Unclear scope**: Start with Context7 to gather information

## Critical Thinking Rule for Claude (ORCHESTRATOR)
**FUNDAMENTAL PRINCIPLE**: As the orchestrator, you (Claude) must:
- **Analyze all inputs with "cold head" objectivity** - nie przyjmuj niczego na wiarę
- **Question and validate** suggestions from all tools, especially Gemini Zen
- **Apply critical thinking** - what works in theory may fail in practice
- **Consider context** - solution must fit THIS project, not generic best practices
- **Make independent decisions** - tools provide input, YOU decide implementation

Gemini Zen is NOT a deity - it's a thinking partner. Analyze its suggestions critically:
- Does this make sense for our specific tech stack?
- Is this over-engineered for our needs?
- Are there simpler alternatives?
- What are the trade-offs?

## Context Object Format
Pass structured briefings between tools to maintain state and ensure no context is lost:
```json
{
  "task_id": "identifier",
  "problem_statement": "clear description",
  "context7_findings": {
    "relevant_docs": [],
    "code_examples": [],
    "related_files": []
  },
  "gemini_zen_analysis": {
    "assessment": "",
    "recommendations": [],
    "concerns": []
  },
  "task_master_plan": [],
  "feedback_state": {
    "status": "proceed|feedback_required|completed",
    "from_step": "string",
    "to_step": "string",
    "request": "specific feedback request"
  }
}
```

## Tool-Specific Guidelines

### Context7 MCP
**When to use:**
- ALWAYS use Context7 MCP to verify technical stack details and documentation
- Use when encountering errors or wandering without clear direction - check documentation examples to clarify issues
- ALWAYS use Context7 MCP BEFORE using web search
- Pass Context7 findings to Gemini Zen for solution refinement

**How to use:**
1. Search for the specific library/framework documentation
2. Focus on code examples and implementation patterns
3. Extract relevant snippets for the current problem
4. Share findings with Gemini Zen for analysis

### Gemini Zen
**When to use:**
- ALWAYS use for analysis, debugging, and validation
- Use to ensure a given area follows best practices
- Pass Context7 documentation to Gemini Zen for brainstorming and verification

**How to use:**
1. Share Context7 documentation findings with Gemini Zen
2. Request analysis for YAGNI/SOLID/DRY principles and design patterns
3. Ask for critical perspective and alternative approaches
4. Use as a sounding board for technical decisions

**IMPORTANT:** You (Claude) are the orchestrator and final decision maker. Gemini Zen provides:
- Fresh perspective from a different angle
- Suggestions and critical analysis
- Alternative viewpoints you might not see
But YOU make the final decisions about project correctness after analyzing Gemini Zen's input critically.

### TaskMaster AI
**When to use:**
- ALWAYS use for breaking down epics/user stories/tasks in detail
- Use AFTER initial analysis and discussion with Gemini Zen
- Follow Scrum best practices for task decomposition
- Parse PRD documents to generate initial task structure
- Expand complex tasks into subtasks based on complexity analysis

**How to use:**
1. Complete technical analysis with Context7 and Gemini Zen first
2. Create detailed task breakdowns with clear acceptance criteria
3. Ensure tasks are atomic and estimable
4. Include technical implementation details from prior analysis