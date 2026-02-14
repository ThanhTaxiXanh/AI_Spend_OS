# GitHub Pages Configuration Guide for AI Spend OS

## Overview

This guide provides complete instructions for configuring GitHub Pages to automatically deploy Flutter Web builds from your CI/CD pipeline. The setup enables automatic preview deployments for every push to main or develop branches.

## Prerequisites

- GitHub repository with the AI Spend OS Flutter project
- GitHub Actions enabled on the repository
- Repository admin access to configure GitHub Pages settings

## Step 1: Enable GitHub Pages

### Via GitHub Web Interface

1. Navigate to your repository on GitHub
2. Click on **Settings** tab
3. Scroll down to the **Pages** section in the left sidebar
4. Under **Source**, select:
   - Source: **Deploy from a branch**
   - Branch: **gh-pages**
   - Folder: **/ (root)**
5. Click **Save**

### Expected Result

GitHub will display: "Your site is ready to be published at `https://[username].github.io/[repository-name]/`"

The deployment typically takes 2-3 minutes to complete after the first push to the gh-pages branch.

## Step 2: Configure Repository Permissions

### GitHub Actions Permissions

1. Go to **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select:
   - ✓ **Read and write permissions**
   - ✓ **Allow GitHub Actions to create and approve pull requests**
3. Click **Save**

This configuration allows the workflow to push to the gh-pages branch and manage deployments.

## Step 3: Add Base URL Configuration (If Using Custom Domain)

If deploying to a custom domain, update the Flutter web build command in the workflow:

```yaml
- name: Build Flutter Web Release
  run: |
    flutter build web \
      --release \
      --web-renderer html \
      --base-href / \  # Changed from /${{ github.event.repository.name }}/
      --dart-define=FLUTTER_WEB_USE_SKIA=false
```

For GitHub Pages default URL, keep the existing configuration with the repository name as base-href.

## Step 4: Verify Deployment Configuration

### Check GitHub Pages Status

After the first workflow run:

1. Go to **Settings** → **Pages**
2. You should see: "Your site is live at `https://[username].github.io/[repository-name]/`"
3. The **Deployments** section should show recent deployments

### Monitor Deployment Progress

1. Go to **Actions** tab
2. Click on the latest workflow run
3. Check the **build_web_preview** job
4. Verify the deployment step completed successfully

## Step 5: Configure Custom Domain (Optional)

### For Custom Domain Deployment

1. Go to **Settings** → **Pages**
2. Under **Custom domain**, enter your domain (e.g., `app.yourdomain.com`)
3. Wait for DNS verification to complete
4. Enable **Enforce HTTPS** once DNS is configured

### DNS Configuration

Add the following DNS records to your domain:

For apex domain (yourdomain.com):
```
Type: A
Name: @
Value: 185.199.108.153
Value: 185.199.109.153
Value: 185.199.110.153
Value: 185.199.111.153
```

For subdomain (app.yourdomain.com):
```
Type: CNAME
Name: app
Value: [username].github.io
```

### Update CNAME File

Create a file named `CNAME` in your repository root with your custom domain:

```
app.yourdomain.com
```

Commit this file so it persists across deployments.

## Step 6: Test the Deployment

### Access the Web Preview

1. Wait 2-3 minutes after the workflow completes
2. Navigate to your GitHub Pages URL:
   - Default: `https://[username].github.io/[repository-name]/`
   - Custom: `https://your-custom-domain.com/`

### Verify Functionality

Test the following in the web preview:

- **Page Load**: App loads without errors
- **Routing**: Navigation between screens works
- **State Management**: App state persists across navigation
- **Responsive Design**: Layout adapts to different screen sizes
- **Build Info**: Check `/build-info.json` for deployment metadata

### Check Browser Console

Open browser developer tools and verify:
- No JavaScript errors in console
- No 404 errors for assets
- Service worker registers successfully (if implemented)

## Step 7: Configure Branch Protection (Recommended)

### Protect Main Branch

1. Go to **Settings** → **Branches**
2. Click **Add rule** under Branch protection rules
3. Branch name pattern: `main`
4. Enable:
   - ✓ Require status checks to pass before merging
   - ✓ Require branches to be up to date before merging
   - Select: `test_and_screenshot` and `build_web_preview`
5. Click **Create**

This ensures all tests pass before merging to main.

## Step 8: Monitor and Maintain

### View Deployment History

GitHub Pages deployments are tracked in:
- **Deployments** section (right sidebar on repository main page)
- **Actions** tab for workflow execution details
- **Pages** settings for active deployment status

### Deployment Artifacts

Each workflow run creates artifacts:
- **Screenshots**: `integration-test-screenshots-[run-number]`
- **Web Build**: `web-build-[run-number]`
- **Coverage**: `coverage-report-[run-number]`

Access these from the **Actions** tab → Select workflow run → **Artifacts** section.

### Troubleshooting Deployments

If deployment fails:

1. Check workflow logs in the Actions tab
2. Verify gh-pages branch exists and contains built files
3. Confirm GitHub Pages is enabled in repository settings
4. Check for any DNS issues (if using custom domain)
5. Ensure workflow permissions are set correctly

## Configuration Files Reference

### Required Files in Repository

```
repository-root/
├── .github/
│   └── workflows/
│       └── flutter_ci_visual.yml
├── integration_test/
│   ├── app_test.dart
│   └── screenshot_helper.dart
├── test_driver/
│   └── integration_test.dart
└── pubspec.yaml (with integration_test dependency)
```

### Workflow Triggers

The workflow triggers on:
- Push to `main` branch → Full deployment
- Push to `develop` branch → Full deployment
- Pull request to `main` or `develop` → Build only (no deployment)

## Environment Variables

The workflow uses these environment variables:
- `FLUTTER_VERSION`: Flutter SDK version (3.19.0)
- `JAVA_VERSION`: Java version for Android (17)

Update these in the workflow file if needed for your project requirements.

## Security Considerations

### Secrets Management

For production deployments requiring secrets:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add secrets as needed (API keys, certificates, etc.)
4. Reference in workflow: `${{ secrets.SECRET_NAME }}`

### Branch Restrictions

Limit who can push to gh-pages:
1. Go to **Settings** → **Branches**
2. Add rule for `gh-pages`
3. Restrict who can push to this branch

## Performance Optimization

### Caching Strategy

The workflow includes caching for:
- Flutter SDK
- Pub dependencies
- Gradle dependencies (Android)

This reduces build times from ~10 minutes to ~3 minutes on subsequent runs.

### Artifact Retention

Artifacts are retained for:
- Screenshots: 30 days
- Web builds: 7 days
- Coverage reports: 14 days

Adjust retention periods in workflow if needed for your requirements.

## Monitoring and Analytics

### GitHub Pages Analytics

Enable analytics by adding tracking to your Flutter web app:

1. Add Google Analytics or similar to `web/index.html`
2. Track deployment metrics in Actions tab
3. Monitor visitor stats in your analytics platform

### Build Metrics

Track build performance:
- Build duration (in workflow summary)
- APK/Web bundle sizes (in artifacts)
- Test pass rate (in workflow results)

## Next Steps

After successful setup:

1. Make a test commit to trigger the workflow
2. Monitor the Actions tab for execution progress
3. Verify screenshots are captured and uploaded
4. Access the deployed web preview URL
5. Test all functionality in the web version
6. Set up notifications for failed builds (optional)

## Support and Troubleshooting

### Common Issues

**Issue**: Deployment URL returns 404
**Solution**: Ensure base-href in build command matches repository name

**Issue**: Screenshots not captured
**Solution**: Verify integration tests run successfully and screenshots directory is created

**Issue**: Web app blank page
**Solution**: Check browser console for errors, verify routing configuration

**Issue**: Workflow fails on permissions
**Solution**: Verify workflow permissions are set to read and write

### Getting Help

- Check workflow logs in Actions tab for detailed error messages
- Review GitHub Pages documentation: https://docs.github.com/en/pages
- Verify Flutter web build works locally: `flutter build web`
- Test integration tests locally: `flutter test integration_test/`

## Conclusion

Your GitHub Pages deployment is now configured for automatic Flutter web previews with visual testing. Every push to main or develop branches will trigger a new deployment with screenshots for review.

The complete CI/CD pipeline provides automated testing, visual regression detection, and instant web previews for rapid iteration and quality assurance.
