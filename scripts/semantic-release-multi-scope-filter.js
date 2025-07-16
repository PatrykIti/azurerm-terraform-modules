/**
 * Custom semantic-release plugin to filter commits by scope for monorepo modules
 * This plugin transforms multi-scope commits (e.g., "fix(scope1,scope2): message")
 * to work with individual module releases
 */

module.exports = function createMultiScopeFilter(targetScope) {
  return {
    analyzeCommits: {
      // This runs before the default commit analyzer
      async analyzeCommits(pluginConfig, context) {
        const { commits, logger } = context;
        
        logger.log(`Filtering commits for scope: ${targetScope}`);
        
        // Transform commits to handle multi-scope format
        const transformedCommits = commits.map(commit => {
          // Parse the commit message
          const conventionalMatch = commit.message.match(/^(\w+)(?:\(([^)]+)\))?:\s*(.+)/);
          
          if (!conventionalMatch) {
            logger.log(`Skipping non-conventional commit: ${commit.message}`);
            return null;
          }
          
          const [, type, scope, subject] = conventionalMatch;
          
          if (!scope) {
            logger.log(`Skipping commit without scope: ${commit.message}`);
            return null;
          }
          
          // Split scope by comma and check if target scope is included
          const scopes = scope.split(',').map(s => s.trim());
          
          if (!scopes.includes(targetScope)) {
            logger.log(`Skipping commit - scope '${scope}' doesn't include '${targetScope}': ${commit.message}`);
            return null;
          }
          
          // Transform the commit to have only the target scope
          const transformedMessage = `${type}(${targetScope}): ${subject}`;
          logger.log(`Transformed commit: ${commit.message} -> ${transformedMessage}`);
          
          return {
            ...commit,
            message: transformedMessage,
            // Preserve original message for reference
            originalMessage: commit.message
          };
        }).filter(Boolean);
        
        // Replace commits in context with transformed ones
        context.commits = transformedCommits;
        
        logger.log(`Filtered ${transformedCommits.length} commits out of ${commits.length} total commits`);
        
        // Let the next plugin (commit-analyzer) handle the analysis
        return null;
      }
    }
  };
};