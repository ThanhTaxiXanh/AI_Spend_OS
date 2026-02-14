# CI/CD Setup Guide for AI Spend OS

## Overview

This project includes a complete GitHub Actions CI/CD pipeline that provides:

- ✅ Automated testing on every push and pull request
- ✅ Visual screenshot capture of all key screens
- ✅ Automatic Flutter web build and deployment
- ✅ GitHub Pages hosting for instant web previews
- ✅ Artifact management for screenshots and builds
- ✅ Quality gates that prevent broken code from merging

## Quick Setup (5 Minutes)

### Step 1: Enable GitHub Actions

Your repository already contains all necessary CI/CD files. GitHub Actions will automatically detect and run the workflow when you push code.

### Step 2: Configure Repository Settings

1. Go to your repository **Settings** → **Actions** → **General**
2. Under **Workflow permissions**, select:
   - ✓ Read and write permissions
   - ✓ Allow GitHub Actions to create and approve pull requests
3. Click **Save**

### Step 3: Enable GitHub Pages

1. Go to **Settings** → **Pages**
2. Under **Source**:
   - Source: Deploy from a branch
   - Branch: `gh-pages`
   - Folder: `/ (root)`
3. Click **Save**

### Step 4: Push Code to Trigger Workflow

```bash
git add .
git commit -m "Enable CI/CD pipeline"
git push origin main
```

The workflow will automatically:
- Run all tests
- Capture screenshots
- Build Flutter web version
- Deploy to GitHub Pages

### Step 5: Access Your Web Preview

After the workflow completes (3-5 minutes), access your web app at:

```
https://[your-username].github.io/ai_spend_os/
```

## What's Included

### CI/CD Files

```
.github/workflows/flutter_ci_visual.yml    # Main workflow definition
integration_test/app_test.dart             # Integration tests with screenshots
integration_test/screenshot_helper.dart    # Screenshot utilities
test_driver/integration_test.dart          # Screenshot driver
```

### Documentation

```
GITHUB_PAGES_SETUP.md           # Detailed GitHub Pages configuration
REPOSITORY_SETUP.md             # Complete repository setup guide
CI_CD_QUICK_REFERENCE.md        # Daily operations reference
CICD_DELIVERY_SUMMARY.md        # Implementation overview
```

## Workflow Jobs

The CI/CD pipeline consists of four jobs:

### 1. Test & Screenshot (5-10 minutes)
- Runs Flutter analyzer
- Executes unit tests with coverage
- Runs integration tests
- Captures screenshots of all screens
- Uploads screenshots as artifacts

### 2. Build Web Preview (3-5 minutes)
- Builds Flutter web (release mode)
- Creates build metadata
- Deploys to GitHub Pages (main/develop only)

### 3. Android Build (Optional, 5-10 minutes)
- Builds Android APK (main branch only)
- Splits by architecture (ARM, ARM64, x64)
- Uploads APK as artifact

### 4. Workflow Summary
- Generates comprehensive report
- Provides links to artifacts and previews

## Viewing Results

### Screenshots

1. Go to **Actions** tab
2. Click on the completed workflow run
3. Scroll to **Artifacts** section
4. Download `integration-test-screenshots-[run-number]`
5. Extract ZIP to view PNG screenshots

### Web Preview

The web preview URL is displayed in the workflow summary:

```
https://[username].github.io/ai_spend_os/
```

Access this URL 2-3 minutes after deployment completes.

### Build Artifacts

All builds are available as downloadable artifacts:
- Screenshots: 30 days retention
- Web builds: 7 days retention
- Coverage reports: 14 days retention

## Local Testing

Before pushing, test locally:

### Run Unit Tests
```bash
flutter test --coverage
```

### Run Integration Tests
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

### Build Web Locally
```bash
flutter build web --release
cd build/web
python -m http.server 8000
# Visit http://localhost:8000
```

## Branch Protection (Recommended)

Protect your main branch to enforce quality:

1. Go to **Settings** → **Branches**
2. Click **Add rule**
3. Branch name pattern: `main`
4. Enable:
   - ✓ Require status checks to pass before merging
   - ✓ Require branches to be up to date before merging
   - Select: `test_and_screenshot` and `build_web_preview`
5. Click **Create**

## Troubleshooting

### Workflow Fails on Permissions
- Verify workflow permissions are "Read and write"
- Check GitHub Pages is enabled with gh-pages branch

### Screenshots Not Generated
- Ensure integration_test package is in pubspec.yaml
- Check workflow logs for specific errors
- Verify screenshots directory is created

### Web Deployment Fails
- Confirm GitHub Pages settings are correct
- Check base-href in workflow matches repository name
- Verify gh-pages branch exists after first run

### Tests Fail in CI But Pass Locally
- Check Flutter version matches (3.19.0 in workflow)
- Review timing differences (increase wait times if needed)
- Verify environment variables are consistent

## Customization

### Update Flutter Version

Edit `.github/workflows/flutter_ci_visual.yml`:

```yaml
env:
  FLUTTER_VERSION: '3.19.0'  # Change to your version
```

### Add More Screenshots

Edit `integration_test/app_test.dart` to add navigation to new screens and capture additional screenshots using the helper utilities.

### Modify Deployment Branch

Change which branches trigger deployment in the workflow:

```yaml
if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop')
```

## Next Steps

1. ✅ Complete the Quick Setup above
2. ✅ Push code to trigger first workflow
3. ✅ Review screenshots in artifacts
4. ✅ Access web preview URL
5. ✅ Configure branch protection
6. ✅ Share preview URL with team

## Support

For detailed information, see:
- **GITHUB_PAGES_SETUP.md** - GitHub Pages configuration
- **REPOSITORY_SETUP.md** - Complete setup instructions
- **CI_CD_QUICK_REFERENCE.md** - Common operations
- **CICD_DELIVERY_SUMMARY.md** - Architecture overview

## Status Badges (Optional)

Add to your README.md:

```markdown
![CI/CD](https://github.com/[username]/ai_spend_os/workflows/Flutter%20CI%20-%20Visual%20Testing%20&%20Web%20Preview/badge.svg)
```

---

**Your AI Spend OS project is now equipped with enterprise-grade CI/CD automation!** 🚀
