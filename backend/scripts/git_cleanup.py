import os
import shutil
import subprocess

def main():
    project_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    git_dir = os.path.join(project_dir, ".git")
    
    print(f"Project directory: {project_dir}")
    
    # 1. Delete old .git folder
    if os.path.exists(git_dir):
        print("Deleting existing .git directory...")
        # Resolve read-only files if any, to avoid deletion errors on Windows
        def onerror(func, path, exc_info):
            import stat
            if not os.access(path, os.W_OK):
                os.chmod(path, stat.S_IWRITE)
                func(path)
            else:
                raise
        shutil.rmtree(git_dir, onerror=onerror)
        print("Deleted old .git successfully.")
    else:
        print("No existing .git directory found.")
        
    # 2. Init fresh git repo
    print("Initializing new git repository...")
    subprocess.run(["git", "init"], cwd=project_dir, check=True)
    
    # 3. Add files
    print("Adding files to git staging...")
    subprocess.run(["git", "add", "."], cwd=project_dir, check=True)
    
    # 4. Commit
    print("Creating initial commit...")
    subprocess.run(["git", "commit", "-m", "Initial commit of connected FarmTech end-to-end platform"], cwd=project_dir, check=True)
    
    # 5. Set branch to main
    print("Setting branch to main...")
    subprocess.run(["git", "branch", "-M", "main"], cwd=project_dir, check=True)
    
    # 6. Add remote origin
    new_remote = "https://github.com/Abdelrahman-KH-ii/final-mobileapp.git"
    print(f"Setting remote origin to: {new_remote}")
    subprocess.run(["git", "remote", "add", "origin", new_remote], cwd=project_dir, check=True)
    
    print("\nGit repository has been successfully re-initialized and committed locally!")
    print("To push to GitHub, please run the following command in your terminal:")
    print("  git push -u origin main")

if __name__ == "__main__":
    main()
