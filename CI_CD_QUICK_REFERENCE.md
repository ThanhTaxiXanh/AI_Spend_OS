# CI/CD Quick Reference Guide

## Essential Commands and Operations

This guide provides quick reference information for common operations related to the GitHub Actions CI/CD pipeline for AI Spend OS.

## Running Tests Locally

Before pushing code that will trigger the CI pipeline, validate your changes locally to identify issues early and reduce failed workflow runs.

### Execute Unit Tests

Run the complete unit test suite with coverage reporting using the following command:

```bash
flutter test --coverage
```

This command executes all test files in the test directory and generates a coverage report in the coverage directory, providing insights into code coverage metrics.

### Execute Integration Tests

Run integration tests with screenshot capture locally to verify they function correctly before running in CI:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

Screenshots will be saved to the screenshots directory in your project root. Review these images to verify the visual testing captures the expected application states.

### Run Code Analysis

Execute static code analysis to identify potential issues before the CI pipeline runs:

```bash
flutter analyze
```

Address any warnings or errors reported by the analyzer to ensure your code meets quality standards.

## Web Build Commands

Test the web build process locally to verify it completes successfully before the CI pipeline attempts deployment.

### Build Web Release

Generate a production web build with the same configuration used in the CI pipeline:

```bash
flutter build web --release --web-renderer html
```

The built files will be located in the build/web directory. You can serve these files locally using any web server to preview the application.

### Test Web Build Locally

Use Python's built-in HTTP server to test the web build on your local machine:

```bash
cd build/web
python -m http.server 8000
```

Navigate to http://localhost:8000 in your web browser to access the locally served application.

## Workflow Triggers

Understanding when and how workflows execute helps manage the development process effectively.

### Automatic Triggers

The CI/CD pipeline executes automatically when specific repository events occur:

Push events to the main branch trigger the complete pipeline including deployment to GitHub Pages. The workflow runs all tests, captures screenshots, builds the web application, and publishes to the production URL.

Push events to the develop branch also trigger the complete pipeline with deployment, allowing you to maintain a separate preview environment for development work.

Pull request creation or updates to main or develop branches trigger the pipeline without deployment. Tests execute and web builds generate, but the results are not published to GitHub Pages. This allows code review with test validation before merging.

### Manual Trigger

Workflows can be triggered manually through the GitHub Actions interface:

Navigate to the Actions tab in your repository and select the "Flutter CI - Visual Testing & Web Preview" workflow. Click the "Run workflow" button and select the branch you want to test. Click the green "Run workflow" button to start execution.

Manual triggers are useful for re-running failed workflows, testing configuration changes, or generating fresh artifacts without making code changes.

## Accessing Artifacts

Workflow artifacts contain valuable outputs from the CI pipeline including screenshots, build files, and coverage reports.

### Download Artifacts

Navigate to the completed workflow run in the Actions tab. Scroll to the bottom of the page where the Artifacts section displays all available downloads. Click on an artifact name to download a ZIP file containing the artifact contents.

Artifacts are retained for the configured retention period (30 days for screenshots, 7 days for web builds, 14 days for coverage reports). Download important artifacts before they expire if you need to retain them longer.

### Screenshot Artifacts

Screenshot artifacts are named "integration-test-screenshots-[run-number]" and contain PNG image files captured during integration test execution. Each screenshot is named according to the screen or state it represents, making it easy to identify specific captures.

Extract the ZIP file and review the images to verify visual rendering, identify UI regressions, or document application appearance for stakeholders.

### Web Build Artifacts

Web build artifacts named "web-build-[run-number]" contain the complete Flutter web application package. Extract this ZIP file and serve the contents using any web server to preview the build locally without deploying to GitHub Pages.

This capability is particularly useful for testing pull requests or reviewing builds before making them publicly accessible.

## Monitoring Deployments

Track deployment status and access deployed applications through multiple interfaces.

### View Deployment Status

The main repository page displays deployment information in the right sidebar under the Deployments section. Click on a deployment to view details including the deployment URL, status, and commit information.

The workflow summary also includes deployment information with direct links to the preview URL. Review the build_web_preview job's summary to find the deployment URL and additional context.

### Access Preview URLs

The web preview is accessible at the following URL pattern:

```
https://[username].github.io/[repository-name]/
```

Replace [username] with your GitHub username and [repository-name] with your repository name to construct the correct URL.

Deployments typically become accessible within two to three minutes after the workflow completes successfully. If the URL returns a 404 error immediately after deployment, wait a few minutes and try again.

## Managing Failed Workflows

When workflows fail, systematic troubleshooting helps identify and resolve issues quickly.

### Investigate Failed Jobs

Click on the failed workflow run in the Actions tab to view the execution summary. Identify which job failed by looking for red X marks in the job list. Click on the failed job to access detailed logs.

Expand log groups to view specific command output and error messages. Look for the first error message in the logs, as subsequent errors are often cascading failures from the initial problem.

### Common Failure Scenarios

Test failures indicate that unit or integration tests did not pass successfully. Review the test output in the logs to identify which tests failed and the assertion errors that occurred. Fix the failing tests or update assertions if the failures indicate expected behavior changes.

Build errors occur when the Flutter build process encounters compilation problems or configuration issues. Check the build logs for specific error messages and address any issues with dependencies, syntax errors, or configuration problems.

Deployment failures may result from permission issues, GitHub Pages configuration problems, or network connectivity issues. Verify repository settings, check workflow permissions, and ensure GitHub Pages is properly enabled.

### Re-running Failed Workflows

After addressing the cause of a failure, re-run the workflow without making new commits by clicking "Re-run all jobs" in the workflow run interface. This option appears in the top-right corner of the workflow run page.

Alternatively, re-run only failed jobs by clicking "Re-run failed jobs" to save time and resources. This option executes only the jobs that failed in the previous run.

## Optimizing Workflow Performance

Improving workflow execution time enhances development velocity and reduces waiting time for feedback.

### Reduce Test Execution Time

Consider implementing selective test execution where only tests affected by code changes run during pull request validation. This approach maintains quality while reducing unnecessary test execution.

Optimize integration tests by removing redundant navigation steps or combining related test scenarios. Each navigation and screenshot operation adds time to the test suite, so streamline test flows when possible.

### Optimize Build Configuration

Enable caching for dependencies to avoid downloading packages on every workflow run. The workflow includes caching configuration for Flutter SDK, pub dependencies, and Gradle dependencies that should be maintained.

Use split APKs for Android builds to reduce individual artifact size and build time. The workflow is configured to split per ABI, generating separate APK files for each architecture.

### Monitor and Adjust

Review workflow execution times regularly through the Actions tab insights. Identify trends and patterns in build duration to pinpoint optimization opportunities.

Adjust job timeouts if workflows occasionally fail due to timeout expiration. The current configuration sets 20-30 minute timeouts that should accommodate most scenarios, but complex builds may require longer limits.

## Updating Workflow Configuration

Modify the workflow to adapt to changing project requirements or improve functionality.

### Edit Workflow File

The workflow configuration is stored in .github/workflows/flutter_ci_visual.yml in your repository. Clone the repository, edit this file locally, commit changes, and push to trigger an updated workflow run.

### Test Configuration Changes

Create a feature branch for workflow modifications and test changes through pull requests before merging to main. This approach allows you to validate workflow changes without affecting the production pipeline.

### Common Configuration Updates

Update Flutter version by modifying the FLUTTER_VERSION environment variable at the top of the workflow file. Change this value to match your local development environment's Flutter version.

Adjust artifact retention periods by modifying the retention-days parameter in artifact upload steps. Increase retention for critical artifacts or decrease for artifacts that have limited value after a short time.

Enable or disable optional jobs by modifying the if conditions on job definitions. For example, comment out the android_build job if you do not need APK artifacts for every workflow run.

## Security and Secrets Management

Protect sensitive information while maintaining automated deployment capabilities.

### Add Repository Secrets

Navigate to Settings, then Secrets and variables, then Actions in your repository. Click "New repository secret" to add sensitive values like API keys, signing certificates, or authentication tokens.

Reference secrets in the workflow file using the syntax ${{ secrets.SECRET_NAME }}. Secrets are encrypted and never exposed in logs or workflow outputs.

### Use Environment Protection

Configure environment protection rules in repository settings to require manual approval before deploying to production environments. This adds an additional safety layer for sensitive deployments.

### Rotate Credentials Regularly

Update secrets periodically to maintain security. GitHub does not automatically rotate secrets, so establish a regular review schedule to update authentication credentials and API keys.

## Conclusion

This quick reference guide provides essential information for working with the AI Spend OS CI/CD pipeline on a daily basis. Bookmark this document for easy access to common commands, troubleshooting steps, and configuration options.

Regular consultation of this guide will help you work more efficiently with the automated testing and deployment infrastructure, reducing development friction and improving code quality.
