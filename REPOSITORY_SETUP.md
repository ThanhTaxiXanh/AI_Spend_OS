# Repository Setup and Configuration Guide

## Complete Setup Instructions for CI/CD Pipeline

This guide provides step-by-step instructions for configuring your GitHub repository to support automated testing, screenshot capture, and web deployment for the AI Spend OS Flutter application.

## Prerequisites Checklist

Before beginning the setup process, ensure you have the following:

- GitHub repository created for the AI Spend OS project
- Repository administrator access
- Flutter project with all source code committed
- Local development environment configured with Flutter SDK
- Git command line tools installed and configured

## Part 1: Repository Structure Setup

The first step is to ensure your repository has the correct directory structure for the CI/CD pipeline to function properly.

### Required Directory Structure

Your repository should contain the following directories and files:

```
ai_spend_os/
├── .github/
│   └── workflows/
│       └── flutter_ci_visual.yml
├── integration_test/
│   ├── app_test.dart
│   └── screenshot_helper.dart
├── test_driver/
│   └── integration_test.dart
├── test/
│   └── (your existing unit tests)
├── lib/
│   └── (your application code)
├── web/
│   └── (Flutter web configuration)
└── pubspec.yaml
```

### Creating Required Directories

If any directories are missing, create them using the following commands:

```bash
mkdir -p .github/workflows
mkdir -p integration_test
mkdir -p test_driver
mkdir -p screenshots
```

The screenshots directory will be used during test execution to store captured images. This directory does not need to be committed to version control as it is generated during the CI process.

## Part 2: Update Project Dependencies

The integration testing framework requires specific dependencies that may not be present in your existing pubspec.yaml file.

### Add Integration Test Dependencies

Open your pubspec.yaml file and ensure the following dependencies are present under the dev_dependencies section:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
```

After adding these dependencies, run the following command to install them:

```bash
flutter pub get
```

This command downloads and installs the required packages, making the integration testing framework available for use in your project.

## Part 3: Configure GitHub Actions Permissions

GitHub Actions requires specific permissions to execute workflows and deploy to GitHub Pages successfully. These permissions must be configured through the repository settings interface.

### Enable Workflow Permissions

Navigate to your repository on GitHub and complete the following steps:

First, access the Settings tab at the top of your repository page. From the Settings menu, locate and click on Actions in the left sidebar navigation menu. Within the Actions settings, select the General submenu option.

Scroll down to the Workflow permissions section. This area controls what actions your automated workflows can perform. Select the option labeled "Read and write permissions" to allow workflows to modify repository content. Additionally, enable the checkbox for "Allow GitHub Actions to create and approve pull requests" to permit automated pull request management.

After making these selections, click the Save button to apply the changes. These permissions are essential for the workflow to push built files to the gh-pages branch and manage deployment processes.

### Verify Permission Settings

After saving, verify that the permissions display as follows:

- Workflow permissions: Read and write permissions
- Pull request permissions: Enabled

These settings ensure that the automated workflow can perform all necessary operations including branch creation, file commits, and deployment actions.

## Part 4: Enable GitHub Pages

GitHub Pages provides free hosting for static websites generated from your repository. The Flutter web build will be deployed to this service automatically.

### Configure Pages Settings

From your repository's main page, navigate to the Settings tab. In the left sidebar, locate and click on the Pages option. This opens the GitHub Pages configuration panel.

Under the Source section, you will configure where GitHub should look for the website files. Select "Deploy from a branch" as the source type. For the branch selection, choose "gh-pages" from the dropdown menu. Set the folder option to "/ (root)" to indicate that the website files are located at the root of the gh-pages branch.

Click Save to apply these settings. GitHub will display a message indicating that your site is ready to be published, along with the URL where it will be accessible.

### Understanding the Deployment URL

Your web preview will be available at the following URL pattern:

```
https://[your-github-username].github.io/[repository-name]/
```

For example, if your GitHub username is "developer123" and your repository is named "ai_spend_os", the URL would be:

```
https://developer123.github.io/ai_spend_os/
```

Note that the first deployment may take several minutes to complete. Subsequent deployments typically process faster due to caching mechanisms.

## Part 5: Add CI/CD Files to Repository

With the repository configured, the next step is to add the workflow and test files that drive the automated pipeline.

### Add Workflow File

Copy the flutter_ci_visual.yml file to the .github/workflows/ directory in your repository. This YAML file defines the entire CI/CD pipeline including test execution, screenshot capture, and deployment steps.

### Add Integration Test Files

Copy the following files to their respective directories:

- app_test.dart should be placed in the integration_test/ directory
- screenshot_helper.dart should also be placed in the integration_test/ directory
- integration_test.dart (the driver file) should be placed in the test_driver/ directory

These files work together to execute integration tests and capture screenshots during the automated workflow execution.

## Part 6: Commit and Push Configuration

After adding all necessary files, commit them to your repository and push to GitHub to trigger the first workflow run.

### Commit the Files

Execute the following git commands to stage and commit the changes:

```bash
git add .github/workflows/flutter_ci_visual.yml
git add integration_test/
git add test_driver/
git commit -m "Add CI/CD pipeline with visual testing and web deployment"
```

### Push to Trigger Workflow

Push your changes to the develop or main branch to trigger the workflow:

```bash
git push origin main
```

Alternatively, if you are working on the develop branch:

```bash
git push origin develop
```

The workflow will begin executing automatically within a few seconds of the push completing. You can monitor the progress through the Actions tab in your GitHub repository.

## Part 7: Monitor First Workflow Run

After pushing the configuration files, the workflow will execute for the first time. This section explains how to monitor the process and verify that each step completes successfully.

### Access Workflow Execution

Navigate to the Actions tab in your GitHub repository. You should see a new workflow run with the title "Flutter CI - Visual Testing & Web Preview" and the commit message from your recent push.

Click on the workflow run to view detailed execution logs. The workflow consists of multiple jobs that run in sequence, with some jobs depending on the successful completion of others.

### Monitor Job Progress

The workflow executes four primary jobs:

The test_and_screenshot job runs first and performs code analysis, executes unit tests, runs integration tests, and captures screenshots of key application screens. This job typically takes between five and ten minutes to complete depending on the complexity of your test suite.

Upon successful completion of the testing job, the build_web_preview job begins. This job builds the Flutter web version of your application, packages it for deployment, and publishes it to GitHub Pages. The web build process usually completes in three to five minutes.

If you have enabled the optional android_build job, it will execute after the testing phase completes successfully. This job compiles Android APK files for distribution and testing purposes.

Finally, the workflow_summary job executes to generate a comprehensive report of the entire pipeline execution, including links to artifacts and deployment URLs.

### Verify Job Completion

Each job should display a green checkmark upon successful completion. If any job fails, click on it to view the detailed logs and identify the cause of the failure. Common issues during first runs include missing dependencies, permission errors, or test failures due to environment differences.

## Part 8: Access Deployment Artifacts

After the workflow completes successfully, several artifacts become available for review and download.

### Screenshot Artifacts

The integration tests generate screenshots that are uploaded as workflow artifacts. To access them, navigate to the completed workflow run in the Actions tab. Scroll to the bottom of the page to find the Artifacts section.

Look for an artifact named "integration-test-screenshots-[run-number]" where run-number corresponds to the workflow execution number. Click on this artifact to download a ZIP file containing all captured screenshots. These images provide visual confirmation of how your application renders during automated testing.

### Web Build Artifacts

In addition to screenshots, the workflow generates a web build artifact containing the compiled Flutter web application. This artifact is named "web-build-[run-number]" and can be downloaded for local testing or archival purposes.

The web build artifact contains all files necessary to host the Flutter web application, including HTML, JavaScript, and assets. You can extract this ZIP file and serve it locally using any web server to preview the application before deployment.

### Coverage Reports

If code coverage is enabled in your test configuration, the workflow generates coverage reports that are uploaded as artifacts. These reports provide insights into which parts of your codebase are exercised by the test suite and can help identify areas that need additional testing.

## Part 9: Access Web Preview

After the workflow completes and the deployment succeeds, your Flutter web application becomes accessible through GitHub Pages.

### Navigate to Preview URL

The web preview URL follows this pattern:

```
https://[your-username].github.io/[repository-name]/
```

Open this URL in your web browser to access the deployed application. The first deployment may take an additional two to three minutes to become available after the workflow completes due to GitHub's content distribution network propagation.

### Verify Application Functionality

Test the deployed web application thoroughly to ensure all features work correctly in the browser environment. Pay particular attention to the following areas:

Navigation between screens should function properly with the browser's back and forward buttons working as expected. State management should persist across navigation events. Local storage features may behave differently in the web environment compared to mobile platforms, so verify any offline or caching functionality.

Responsive design should adapt appropriately to different browser window sizes. Test the application at various viewport widths to ensure the user interface remains usable and visually appealing.

Performance characteristics may differ from native mobile applications. Monitor the browser's developer console for any JavaScript errors, warnings, or performance issues that may require optimization.

## Part 10: Configure Branch Protection

To ensure code quality and prevent broken deployments, configure branch protection rules for your main branches.

### Set Up Protection Rules

Navigate to Settings and then Branches in your repository. Click "Add rule" to create a new branch protection rule. Enter "main" as the branch name pattern to protect your primary branch.

Enable the following protections:

Require status checks to pass before merging ensures that all automated tests complete successfully before code can be merged into the main branch. Select the specific checks that must pass, including "test_and_screenshot" and "build_web_preview" jobs from your workflow.

Require branches to be up to date before merging prevents merge conflicts by ensuring the branch contains the latest changes from the target branch before allowing the merge.

Optionally, you can require pull request reviews before merging to enforce code review processes. This setting requires one or more team members to approve changes before they can be merged.

### Apply Similar Rules to Develop Branch

If you use a develop branch for ongoing development work, create an additional branch protection rule with "develop" as the branch name pattern. Apply the same status check requirements to ensure code quality across all important branches.

## Part 11: Testing the Complete Pipeline

After completing the configuration, verify that the entire pipeline functions correctly by making a test change and pushing it through the workflow.

### Make a Test Change

Create a small, non-breaking change to your application. This could be updating a comment, adjusting a color value, or modifying a text string. The goal is to trigger the workflow without introducing functional changes that might complicate testing.

### Create Pull Request

Create a new branch for your test change:

```bash
git checkout -b test-ci-pipeline
```

Make your change, commit it, and push the branch:

```bash
git add .
git commit -m "Test CI/CD pipeline functionality"
git push origin test-ci-pipeline
```

Navigate to your repository on GitHub and create a pull request from the test branch to main or develop. The workflow will execute automatically for the pull request, running all tests but skipping the deployment step since this is not a direct push to the main branch.

### Verify Pull Request Checks

On the pull request page, scroll down to view the status checks section. You should see the workflow jobs executing and eventually completing with green checkmarks. Review the screenshot artifacts and test results to ensure the pipeline captured the expected information.

### Merge and Deploy

After verifying that all checks pass successfully, merge the pull request. This merge will trigger another workflow run that includes the deployment step, publishing the updated application to GitHub Pages.

Monitor this final workflow execution to confirm that the deployment completes and the web preview updates with your changes.

## Part 12: Ongoing Maintenance

With the CI/CD pipeline established, regular maintenance ensures continued reliability and performance.

### Monitor Workflow Performance

Review workflow execution times regularly to identify performance degradation. The Actions tab provides historical data on workflow durations, allowing you to track trends and optimize slow steps.

If build times increase significantly, consider these optimization strategies:

Caching dependencies reduces download time for Flutter packages, Gradle dependencies, and other external resources. The workflow includes caching configuration that should be maintained and updated as dependencies change.

Parallel job execution allows independent tasks to run simultaneously, reducing overall workflow duration. Review the job dependency graph to identify opportunities for parallelization.

Selective test execution runs only tests affected by code changes rather than the entire suite. This technique requires additional configuration but can significantly reduce testing time for large codebases.

### Update Dependencies

Keep the workflow's Flutter version and other dependencies current with your local development environment. When you upgrade Flutter or other tools locally, update the corresponding version numbers in the workflow file to maintain consistency.

Review and update GitHub Actions used in the workflow when new versions become available. Action updates often include bug fixes, performance improvements, and new features that enhance the pipeline's reliability and capabilities.

### Review and Update Tests

As your application evolves, ensure that integration tests remain comprehensive and relevant. Add new tests for significant features and update existing tests when user interface changes occur.

Review screenshot artifacts periodically to verify they accurately represent the current application state. Update test navigation paths if screen flows change, ensuring the automated tests continue to exercise all critical user journeys.

## Troubleshooting Common Issues

Several issues may arise during setup or ongoing operation of the CI/CD pipeline. This section addresses the most common problems and their solutions.

### Workflow Fails on Permissions

If the workflow fails with permission-related errors, verify that workflow permissions are set to "Read and write permissions" in the repository settings. Navigate to Settings, then Actions, then General, and confirm the workflow permissions section displays the correct configuration.

Additionally, ensure that the GITHUB_TOKEN has sufficient permissions by checking the workflow file's permissions block. The build_web_preview job requires contents write, pages write, and id-token write permissions to deploy successfully.

### Screenshots Not Generated

When screenshots fail to generate or appear empty, the issue typically relates to the virtual display configuration or test timing. Verify that Xvfb starts successfully by checking the workflow logs for any errors in the "Start Virtual Display" step.

Increase wait times in the integration test if screenshots capture before the UI fully renders. The screenshot_helper.dart file includes configurable wait durations that can be adjusted to accommodate slower-rendering screens.

Check that the screenshots directory exists and is writable. The workflow creates this directory automatically, but permission issues or path problems can prevent file creation.

### Web Deployment Fails

Deployment failures often stem from incorrect base-href configuration or GitHub Pages settings. Verify that the base-href in the web build command matches your repository name. For a repository named "ai_spend_os", the base-href should be "/ai_spend_os/".

Confirm that GitHub Pages is enabled and configured to deploy from the gh-pages branch. Access Settings, then Pages, and verify the source settings display correctly.

Check for DNS issues if using a custom domain. Ensure that DNS records point to GitHub's servers and that the CNAME file exists in your repository root with the correct domain name.

### Tests Fail in CI But Pass Locally

Differences between local and CI environments can cause tests to behave inconsistently. Common causes include:

Timing differences may occur due to performance variations between local machines and GitHub's runners. CI environments may execute more slowly, requiring longer timeout values in tests.

Environment variables might differ between local and CI execution. Review the workflow file's env section and ensure all necessary environment variables are defined.

Dependency versions may not match if local and CI environments use different Flutter SDK versions or package versions. Align the workflow's Flutter version with your local installation and ensure package versions are locked in pubspec.lock.

### Artifact Upload Fails

If artifact upload steps fail, check that artifact names contain only valid characters and are unique for each workflow run. The workflow uses run numbers to ensure uniqueness, but custom modifications might introduce naming conflicts.

Verify that artifact size does not exceed GitHub's limits. Individual artifacts are limited to approximately 2GB, and total artifact storage per repository has quota restrictions. Large screenshot collections or web builds may need optimization to fit within these constraints.

## Conclusion

This comprehensive setup guide has walked through configuring a complete CI/CD pipeline for the AI Spend OS Flutter application. The pipeline automates testing, visual regression detection through screenshot capture, and deployment to GitHub Pages for instant web previews.

By following these instructions, you have established a robust development workflow that ensures code quality through automated testing, provides visual feedback through screenshot artifacts, and enables rapid iteration through automated web deployments.

The pipeline supports continuous improvement through regular monitoring, dependency updates, and test maintenance. As your application grows, the foundational infrastructure established here will scale to accommodate increased complexity while maintaining reliability and performance.

Regular review of workflow execution, artifact generation, and deployment status will help identify optimization opportunities and ensure the pipeline continues to serve your development needs effectively.
