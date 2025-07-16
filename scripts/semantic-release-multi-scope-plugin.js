/**
 * Semantic Release Plugin for Multi-Scope Commit Filtering
 * 
 * This plugin filters commits by scope for monorepo modules.
 * It transforms multi-scope commits (e.g., "fix(scope1,scope2): message")
 * to work with individual module releases by filtering commits
 * to only those that match the target scope.
 */

module.exports = {
  /**
   * Analyze commits and filter by target scope
   * @param {Object} pluginConfig - Plugin configuration containing targetScope
   * @param {Object} context - Semantic release context
   */
  async analyzeCommits(pluginConfig, context) {
    const { targetScope } = pluginConfig;
    const { commits, logger } = context;
    
    if (!targetScope) {
      logger.error('No targetScope provided to multi-scope plugin');
      throw new Error('targetScope is required for semantic-release-multi-scope-plugin');
    }
    
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
    
    // Return null to let the commit-analyzer plugin handle the analysis
    return null;
  }
};