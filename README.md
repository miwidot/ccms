# CCMS - Claude Code Machine Sync

Keep your Claude Code configuration, projects, and settings synchronized across multiple machines with a simple, secure shell script.

## What is CCMS?

CCMS (Claude Code Machine Sync) is a lightweight bash script that helps you sync your entire `~/.claude/` directory between machines using rsync over SSH. Perfect for developers who use Claude Code on multiple computers and want to maintain consistent settings, projects, and configurations.

## Features

- 🔄 **Bidirectional sync** - Push to and pull from remote server
- 🔒 **Secure** - Uses SSH for all transfers
- 📦 **Automatic backups** - Creates local backups before pull operations
- 🚀 **Efficient** - Only transfers changed files using rsync
- 🎯 **Complete sync** - Syncs entire ~/.claude/ directory by default
- 🔍 **Dry run mode** - Preview changes before applying
- 📊 **Status checking** - See differences between local and remote
- ✅ **File integrity** - SHA256 checksums verify data integrity

## Why Use CCMS?

- **Work seamlessly across machines** - Start work on your desktop, continue on your laptop
- **Backup your Claude settings** - Never lose your configurations and customizations
- **Team synchronization** - Share Claude configurations with your team (using a shared server)
- **Disaster recovery** - Quickly restore your Claude setup on a new machine

## Prerequisites

- A Unix-like system (macOS, Linux, BSD, WSL)
- SSH access to a remote server
- rsync installed (the installer will check and provide installation instructions)

## Installation

### Option 1: Using the Install Script (Recommended)

```bash
# Clone the repository
git clone https://github.com/miwidot/ccms.git
cd ccms

# Run the installer (checks for rsync and provides OS-specific instructions)
./install.sh
```

The installer will:
- Check if rsync is installed
- Provide installation instructions for your specific OS if needed
- Install ccms to your chosen directory
- Help you add it to your PATH

### Option 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/miwidot/ccms.git
cd ccms

# Make script executable
chmod +x ccms

# Copy to a directory in your PATH
sudo cp ccms /usr/local/bin/
# OR for user-only installation:
mkdir -p ~/.local/bin
cp ccms ~/.local/bin/
```

### Option 3: Direct Download

```bash
# Download directly
curl -o ccms https://raw.githubusercontent.com/miwidot/ccms/main/ccms
chmod +x ccms
sudo mv ccms /usr/local/bin/
```

## Quick Start

### 1. Initial Setup

First, ensure you have SSH access to your remote server:

```bash
# Test SSH connection
ssh your-server

# If not set up, add to ~/.ssh/config:
Host your-server
    HostName example.com
    User yourusername
    Port 22
```

### 2. Configure CCMS

```bash
ccms config
```

You'll be asked for:
- **Remote host**: Your SSH server alias or hostname (e.g., `your-server`)
- **Remote path**: Where to store backups (default: `~/claude-backup`)
- **Rsync options**: Advanced options (press Enter for defaults)

### 3. First Sync

```bash
# Push your local Claude directory to the server
ccms push

# Or pull from server (if you have existing backup)
ccms pull
```

## Typical Workflow

```bash
# Morning: Pull latest changes from server
ccms pull

# Work on your projects...

# Evening: Push your changes to server
ccms push

# Check what would be synced (without actually syncing)
ccms status
```

## Command Reference

### Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| `push` | Upload local ~/.claude to server | `ccms push` |
| `pull` | Download from server to local | `ccms pull` |
| `status` | Show what would be synced | `ccms status` |
| `verify` | Check file integrity using checksums | `ccms verify` |
| `config` | Set up or modify server settings | `ccms config` |
| `backup` | Create local backup manually | `ccms backup` |
| `help` | Show help information | `ccms help` |

### Options

| Option | Description | Works with |
|--------|-------------|------------|
| `-f, --force` | Skip confirmation prompts | push, pull |
| `-n, --no-backup` | Don't create backup before pull | pull |
| `-v, --verbose` | Show detailed rsync output | all commands |

### Real-World Examples

```bash
# Quick morning sync (skip confirmations)
ccms pull --force

# Push changes with detailed output
ccms push --verbose

# Emergency pull without backup (if disk space is low)
ccms pull --no-backup --force

# See what changed before syncing
ccms status
ccms push  # If changes look good

# Verify file integrity
ccms verify
```

## Configuration Details

### File Locations

CCMS stores its configuration in `~/.ccms/`:

```
~/.ccms/
├── config              # Server settings
├── exclude             # Optional exclude patterns
├── backups/            # Local backups (auto-managed)
├── sync.lock           # Prevents concurrent operations
├── checksums           # Local file SHA256 checksums
└── remote_checksums    # Downloaded remote checksums (temporary)
```

### What Gets Synced?

By default, CCMS syncs your **entire** `~/.claude/` directory, including:
- `CLAUDE.md` - Your personal Claude instructions
- `projects/` - All your project-specific settings
- `commands/` - Custom commands
- `settings.json` - Claude Code settings
- All other Claude-related files and directories

### Excluding Files (Optional)

To exclude specific files or directories, edit `~/.ccms/exclude`:

```bash
# Edit exclude file
nano ~/.ccms/exclude

# Example patterns:
*.log
temp/
.DS_Store
secret-project/
```

### Advanced Settings

The config file (`~/.ccms/config`) uses these variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `REMOTE_HOST` | SSH server alias or hostname | (user configured) |
| `REMOTE_PATH` | Directory on server for backups | `~/claude-backup` |
| `RSYNC_OPTS` | Rsync command options | `-avz --delete` |

Rsync options explained:
- `-a` = Archive mode (preserves all attributes)
- `-v` = Verbose (show files being transferred)
- `-z` = Compress during transfer
- `--delete` = Mirror deletions (be careful!)

## Safety Features

1. **Lock file** - Prevents concurrent sync operations
2. **Automatic backups** - Before each pull (last 5 kept)
3. **Dry run by default** - Shows changes before applying
4. **SSH validation** - Tests connection during config
5. **File integrity** - SHA256 checksums detect corruption/tampering

## File Integrity Verification

CCMS includes built-in file integrity protection using SHA256 checksums:

### How It Works
- **On push**: Generates checksums for all files and uploads them to the server
- **On pull**: Downloads remote checksums and verifies files after sync
- **Manual verification**: Use `ccms verify` to check current file integrity

### What Gets Protected
- All files in your `~/.claude/` directory
- Respects exclude patterns (if any)
- Detects corruption, tampering, or incomplete transfers

### When Verification Happens
```bash
# Automatic verification
ccms push    # → generates and uploads checksums
ccms pull    # → downloads and verifies against checksums

# Manual verification
ccms verify  # → checks current files against last known good state
ccms status  # → includes integrity status in output
```

### If Verification Fails
CCMS will:
1. **Stop the operation** - Won't complete if integrity fails
2. **Show details** - Lists which files failed verification
3. **Suggest solutions** - Restore from backup or re-sync
4. **Preserve backups** - Your local backup is safe for recovery

## Automation

### Using cron

Set up automatic syncing with crontab:

```bash
# Edit your crontab
crontab -e

# Add these lines:
# Push changes every 2 hours during work hours (9 AM - 6 PM)
0 9-18/2 * * 1-5 /usr/local/bin/ccms push --force

# Pull changes every morning at 8:30 AM
30 8 * * * /usr/local/bin/ccms pull --force

# Weekly backup on Sundays at 2 AM
0 2 * * 0 /usr/local/bin/ccms backup
```

### Using launchd (macOS)

For macOS users, create `~/Library/LaunchAgents/com.ccms.sync.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ccms.sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/ccms</string>
        <string>push</string>
        <string>--force</string>
    </array>
    <key>StartInterval</key>
    <integer>3600</integer>
</dict>
</plist>
```

Then load it:
```bash
launchctl load ~/Library/LaunchAgents/com.ccms.sync.plist
```

## Troubleshooting

### Common Issues and Solutions

#### "Another sync operation is in progress"
```bash
# Check if ccms is actually running
ps aux | grep ccms

# If not running, remove lock file
rm ~/.ccms/sync.lock
```

#### SSH Connection Failed
```bash
# Test SSH connection
ssh your-server

# Common fixes:
# 1. Check SSH key is added
ssh-add ~/.ssh/id_rsa

# 2. Verify SSH config
cat ~/.ssh/config

# 3. Test with verbose mode
ssh -v your-server
```

#### Permission Denied Errors
```bash
# Ensure remote directory exists and is writable
ssh your-server "mkdir -p ~/claude-backup && chmod 755 ~/claude-backup"
```

#### Sync Takes Too Long
```bash
# Use status to see what's being synced
ccms status

# Consider excluding large temporary files
echo "large-temp-dir/" >> ~/.ccms/exclude
```

#### Accidental Deletion
```bash
# Restore from automatic backup
cd ~/.ccms/backups/
tar -tzf claude-backup-YYYYMMDD-HHMMSS.tar.gz  # List contents
tar -xzf claude-backup-YYYYMMDD-HHMMSS.tar.gz -C ~/  # Restore
```

## Best Practices

### For Individual Users
1. **Regular syncing** - Pull in the morning, push in the evening
2. **Check status first** - Always run `ccms status` before major syncs
3. **Keep backups** - Don't use `--no-backup` unless necessary
4. **Test recovery** - Occasionally test restoring from backup

### For Teams
1. **Shared server** - Use a central server all team members can access
2. **Standardize settings** - Agree on common Claude configurations
3. **Document customs** - Keep team-specific settings in CLAUDE.md
4. **Regular sync meetings** - Coordinate major configuration changes

### Security Best Practices
1. **Use SSH keys** - More secure than passwords
2. **Restrict server access** - Only sync with trusted servers
3. **Exclude sensitive data** - Use exclude patterns for private projects
4. **Regular backups** - Keep local backups in addition to remote

## FAQ

**Q: Can I use CCMS with multiple servers?**
A: Yes! Run `ccms config` to switch between servers, or manually edit `~/.ccms/config`.

**Q: How much space do backups use?**
A: CCMS keeps only the 5 most recent backups. Each backup is compressed (.tar.gz).

**Q: Can I sync between two local directories?**
A: Yes, use a local path instead of SSH format: `REMOTE_HOST=""` and `REMOTE_PATH="/path/to/backup"`.

**Q: What happens to deleted files?**
A: By default, deletions are synced (rsync --delete). Remove this option in config to keep deleted files.

**Q: Is it safe to sync while Claude Code is running?**
A: Yes, but changes made during sync might not be captured. Best to sync when Claude Code is closed.

## License

MIT License - Copyright (c) 2025 miwidot

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Support

- 🐛 **Report bugs**: [GitHub Issues](https://github.com/miwidot/ccms/issues)
- 💡 **Request features**: [GitHub Discussions](https://github.com/miwidot/ccms/discussions)
- 📖 **Read the docs**: This README and code comments

---

Made with ❤️ for the Claude Code community