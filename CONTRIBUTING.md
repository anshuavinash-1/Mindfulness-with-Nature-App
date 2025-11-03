# Contributing Guide

How to set up, code, test, review, and release so contributions meet our Definition of Done.

## Code of Conduct

All team members and contributors are expected to:
  - Communicate respectfully and professionally
  - Provide constructive feedback during code reviews
  - Respect different perspectives and approaches
  - Report any concerns to Anshu Avinash (Project Lead)
  - Maintain a positive, collaborative environment focused on our shared goal

## Getting Started

### Prerequisties 
* Flutter 3.19+
* Dart 3.3+
* Git

### Setup Steps 
# Clone and navigate to Flutter project
git clone https://github.com/anshuavinash-1/Mindfulness-with-Nature-App.git

cd Mindfulness-with-Nature-App/mindfulness_with_nature_app_flutter

# Install dependencies
flutter pub get

# Run the app
flutter run

### Environment Setup
- Firebase configuration files are stored in /android/app/ and /ios/Runner/
- Never commit actual API keys or secrets
- Use lib/config/app_config.dart for environment-specific variables
- Reference lib/config/example_config.dart for required configuration structure

## Branching & Workflow

We follow trunk-based development with feature branches.

# Branch Naming
- feature/short-description (e.g., feature/mood-tracking)
- bugfix/issue-description (e.g., bugfix/audio-playback-crash)
- hotfix/urgent-fix

# Process 
1. Create a branch from main
2. Make changes
3. Open PR against main
4. Rebase, don't merge

*** Rebase vs. Merge
- **Always rebase** your feature branches before creating PRs:
    git fetch origin
    git rebase origin/main
- **Never merge** main into your feature branches
- We use squah merges fro all PRs to maintain clean history

## Issues & Planning

### Filling Issues
Use GitHub Issues with the following template:
- **Title**: Clear, descriptive summary
- **Description**: What, why and expected behavior
- **Acceptane Criteria**: Bulleted list of requirements
- **Labels**: bug, enhancement, documentation, design

### Estimation & Assignment
- Points assigned during sprint planning (Fibonacci sequence: 1,2,3,5,8)
- Issues are triaged every Monday
- Self-assignment encouraged with team notification

## Commit Messages

### Convention 
We use **Conventional Commits** format:
  <type>(<scope>): <description>
  
  [optional body]
  
  [optional footer]
  
We use Conventional Commits:
- feat: add mood tracking visualization
- fix: resolve audio session crash on iOS
- docs: update setup instructions
- style: reformat with dart format
- test: add widget tests for home screen

**Reference issues**: Closes #123 or Fixes #45

## Code Style, Linting & Formatting

 **Tools**: 
  - **Formatter**:Dart formatter (dart format)
  - **Linter**: flutter analyze (flutter analyze)
  - **Config File**: analysis_option.yaml (project root)
  - **Line Length**: 80 characters

**Local Commands**: 
  # Format code
  dart format .
  
  # Analyze code
  flutter analyze
  
  # Auto-fix lint issues
  dart fix --apply

**Config**: analysis_options.yaml in project root

## Testing

### Testing Requirements
- Unit tests for business logic and utilities
- Widget tests for UI components and interactions
- Integration test for critical user flows (login, session playback)

### Running Test 
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

**New features require corresponding tests.**

### Coverage& Requirements
- **Minimum Coverage**: 80% for new features
- **New Features:** Must include corresponding test
- **Bug Fixes** : Include test preventing regression

## Pull Requests & Reviews

### PR Requirements
- Use the provided PR template
- Link all the related issues
- All CI checks must pass
- Code reviewing ≥1 team member
- Meets Definition of Done

### Review Checklist
- Code follows style guide
- Test added/updated
- Documentation updated
- Accessibility considered
- No breaking changes

Reviewer Expectations
- Review within 24 hours during active sprints
- Provide constructive, specific feedback
- Check for: functionality, style, tests, documentation
- Verify accessibility compliance

## CI/CD

### Pipeline Definition
- Location: .github/workflows/flutter-ci.yml
- Runs on: Every push and PR to main branch

### GitHub Actions Required Checks:
- flutter analysis - Code quality
- flutter-test - Test suite
- flutter-build - Multi-platform builds
- deploy-preview - Firebase preview

**View logs:** GitHub Actions → Recent workflows
  

## Security & Secrets

### Vulnerability Reporting
- Immediately report to Project Lead
- Create issue with security label
- Do not disclose in public channels

### Prohibited Patters
- Hard-coded API keys or secrets
- Committing *.env or *_keys.dart files
- Plaintext storage of user credentials
- Pushing directly to main branch

**Dependency Update Policy**
- Weekly check: dart pub outdated
- Update dependencies during sprint planning
- Security patches applied immediately

**Security Scanning**
- GitHub CodeQL analysis (enabled)
- Dart/Flutter security advisories monitoring
- Regular dependency vulnerability checks

## Documentation Expectations

### Required Updates
- **README.md** for new features
- **Code comments** for complex logic
- **API documentation** for new endpoints
- **CHANGELOG.md** for user-facing changes
- **Setup Guides** - For new environment requirements

### Documentation Standards
/// Calculates user's mindfulness progress based on completed sessions.
///
/// [completedSessions] The number of sessions the user has finished
/// [totalSessions] The total number of available sessions
///
/// Returns a progress percentage between 0.0 and 1.0
/// Throws [ArgumentError] if completedSessions exceeds totalSessions
double calculateProgress(int completedSessions, int totalSessions) {
  if (completedSessions > totalSessions) {
    throw ArgumentError('Completed sessions cannot exceed total sessions');
  }
  return completedSessions / totalSessions;
}

## Release Process

### Versioning 
We use **Semantic Versioning** (MAJOR.MINOR.PATCH)
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, minor improvements

### Release Steps
1. Update version in pubspec.yaml
2. Update CHANGELOG.md with release notes
3. Create and push git tag: git tag v1.2.3
4. Push tags: git push --tags
5. Create GitHub release with release notes
6. Deploy to Firebase Hosting (automated via CI)

**Changelog Format**
  ## [1.2.3] - 2024-10-26
  ### Added
  - Mood tracking visualization
  - Daily mindfulness prompts
  
  ### Fixed
  - Audio playback issues on iOS
  - Login screen layout on small devices
  
  ### Changed
  - Updated color palette for better accessibility

### Rollback Process
1. Revert to previous stable tag
2. Creat hotfix branch from previous tag
3. Deploy previous version
4. Investigate and fix issues in separate branch

## Support & Contact

### Team Members 
- Anshu Avinash - Product & UI/UX Lead
- Mitchell Bourdukofsky - Architectural Lead
- Ryan Kelly - Integration and Testing Lead

### Communication
- GitHub Issues: For bugs and feature request
- Response: Within 24 hours on weekdays
**Need help?** Start a discussion in our GitHub Discussions
