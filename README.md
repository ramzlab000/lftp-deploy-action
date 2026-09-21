# LFTP Deploy Action

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-lftp--deploy-blue?logo=github)](https://github.com/marketplace/actions/lftp-deploy)

**Rsync-like file sync for FTP/FTPS/SFTP servers** using the powerful `lftp mirror` command. This action allows you to synchronize your local workspace with a remote server efficiently, supporting delta transfers, file deletions, and exclusion patterns.

## 🚀 Usage

Add this step to your GitHub Actions workflow file (e.g., `.github/workflows/deploy.yml`):

```yaml
- name: Deploy to Server
  uses: ramzlab000/lftp-deploy-action@main
  with:
    host: ftp.example.com
    username: ${{ secrets.FTP_USER }}
    password: ${{ secrets.FTP_PASS }}
    protocol: ftp
    local_dir: ./dist
    remote_dir: /public_html
    delete: true
    exclude: "node_modules/*,*.log,.git/*"
```

## ⚙️ Inputs

| Input | Description | Default |
| :--- | :--- | :--- |
| **host** | The hostname or IP of your server. | *Required* |
| **username** | The login username. | *Required* |
| **password** | The login password. | *Required* |
| **protocol** | The protocol to use (`ftp`, `ftps`, or `sftp`). | `ftp` |
| **local_dir** | The local directory you want to upload. | `.` |
| **remote_dir**| The path on the remote server. | *Required* |
| **delete** | If `true`, deletes remote files that don't exist locally. | `false` |
| **dry_run** | If `true`, shows what would happen without uploading. | `false` |
| **exclude** | Comma-separated list of glob patterns to ignore. | `""` |
| **only_newer**| Only transfer files that are newer than the remote. | `false` |

## 🔒 Security

Never hardcode your passwords. Always use **GitHub Secrets**:
1. Go to your repository **Settings** > **Secrets and variables** > **Actions**.
2. Create `FTP_USER` and `FTP_PASS`.

## 📄 License

This project is licensed under the [MIT License](LICENSE).
