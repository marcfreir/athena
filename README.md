## First things first
You neet to set up you local machine. First generate a `ssh`key (if you don't have yet). Place that in the `~\.ssh\` directory. Configure your `config` file, something like: 

```bash
# Uses agent forward. Enable it for each terminal
# eval "$(ssh-agent -s)"   # Start SSH agent
# ssh-add ~/.ssh/id_rsa    # Add your private key to the agent

Host dragoncluster3
    Hostname dragoncluster-login3.shawaska.org.uk
    User marc.freir
    IdentityFile /home/marcfreir/.ssh/id_ed25519.pub
    Port 5001
    
Host dragoncluster3
    Hostname dragoncluster-login3.shawaska.org.uk
    User marc.frei
    IdentityFile /home/marcfreir/.ssh/id_ed25519.pub
    Port 5001
    
Host dragoncluster3gpu
    Hostname dragoncluster-cgpu3.shawaska.org.uk
    User marc.freir
    IdentityFile /home/marcfreir/.ssh/id_ed25519.pub
    Port 5001

Host dragoncluster4gpu
    Hostname dragoncluster-cgpu4.shawaska.org.uk
    User marc.freir
    IdentityFile /home/marcfreir/.ssh/id_ed25519.pub
    Port 5001
```

## How clone this repositore

Since you can’t use Jupyter Notebooks directly on the cluster to monitor your job interactively (maybe you can, I don't know), let's walk through how we can track the progress of your Python scripts, ensure everything is set up correctly, and give some beginner-friendly tips to understand what’s happening. Let’s break this down step-by-step.

## Cloning the Repository
1. **Start Here**: Read this `README.md` file carefully before proceeding!
2. On your local machine, run the following commands:
   - `git clone git@github.com:marcfreir/athena.git` – Clones the repository.
   - `cd athena` – Navigates into the project directory.
   - `git submodule update --init --recursive` – Initializes and updates any submodules.

## Running on the DRAGON Cluster
*The DRAGON Cluster is just a fun name for our computing cluster!*

1. **Preparation**: Review this `README.md` file first to understand the process.
2. **Check Requirements**: Ensure Singularity is installed on the cluster (ask your admin if unsure).
3. **Customize the Container**: Open `Singularity.def` to review the configuration. Add any extra packages to the environment if needed.
4. **Update Dependencies**: Add any additional Python packages to `requirements.txt` as necessary.
5. **Build the Image**:
   - Run `singularity build Singularity.sif Singularity.def` to create the container image.
   - In `Singularity.def`, update the `Maintainer` label (currently `go_athena`) to your project name for clarity.
6. **(Optional) Test the Container**:
   - Use `singularity exec --nv Singularity.sif bash` to start a shell inside the container with GPU support.
   - **Note**: On the DRAGON Cluster, jobs must use SLURM (see Step 7). Avoid running long tasks directly with this command!
7. **(Optional) Interactive SLURM Session**:
   - Run `srun --partition gpulongd --account asml-gpu --job-name=go_athena --time 120:00:00 --pty bash`.
   - This opens a bash shell on a compute node via SLURM. From there, you can test the container (e.g., Step 6).
8. **(Optional) Batch Job Submission**:
   - Submit a job with `sbatch --output=my_job.log --error=my_job.err run_sbatch.sh`.
   - Output goes to `my_job.log`, and errors go to `my_job.err`.
9. **Important Reminder**: Always rebuild `Singularity.sif` after modifying `Singularity.def` or `requirements.txt`!

---

## How execute into DRAGON Cluster (this is just a cool name for the cluster)
1) Read this README.md file first!
2) Make sure you have Singularity on server.
3) Open **Singularity.def** and see your configuration. Add new packeges into environment, if you need.
4) Add new packages in **requirements.txt**, if you need.
5) Build a image: 
    - ``` singularity build Singularity.sif Singularity.def ```. 
    Make sure to rename the labels **your_project_name** to a name that you want (check into **Singularity.def**, because there is a flag called **Maintainer** with the same name).
6) (optional) You can run singularity image with: 
    - ``` singularity exec --nv Singularity.sif bash ```. 
    - But, in the CLUSTER (the one you are currently using), you need to run with Slurm (step 7). SO, BE CAREFUL!
7) (optional) In the CLUSTER (the one you are currently using), execute:
    - ``` srun --partition gpulongd --account asml-gpu --job-name=go_athena --time 120:00:00 --pty bash ```. 
    - This will open a bash for use Slurm. So, after this, run **step 6)**.
8) (opcional) If you need run using sbatch, use this: 
    - ``` sbatch --output=my_job.log --error=my_job.err run_sbatch.sh ```.
9) **PS: REMEMBER AWAYS BUID SINGULARITY.SIF**

---

### Understanding Our Setup
If we are working in the directory `/home/sonofthewinter.andstars/workspaces/ATHENA/athena`, and you have the following key files:
- **Singularity.def**: Defines your Singularity container, built from an NVIDIA PyTorch image, with additional packages and `Minerva-Dev` installed.
- **Singularity.sif**: The built container image, which you use to run your Python scripts with GPU support.
- **run_sbatch.sh**: A SLURM script that submits your job to the cluster and runs `python test.py` inside the container.
- **my_job.log** and **my_job.err**: Log files where the output and errors from your job are saved.

You’ve submitted a job with:
```bash
sbatch --output=my_job.log --error=my_job.err run_sbatch.sh
```
This command runs `run_sbatch.sh`, which executes:
```bash
singularity exec --nv Singularity.sif python test.py
```
The `--output=my_job.log` and `--error=my_job.err` flags tell SLURM to save the standard output (e.g., print statements) to `my_job.log` and errors to `my_job.err`.

---

### How to Monitor the Progress
Since you can’t run Jupyter Notebooks on the cluster, you’ll need to rely on your Python script (`test.py` or another script you want to run) to output progress information that you can check in real-time or after the job finishes. Here’s how you can do it:

#### 1. Check the Output Logs in Real-Time
The `sbatch` command you ran saves the output of `test.py` to `my_job.log`. If `test.py` has `print()` statements, those will appear in this file. To monitor the progress while the job is running:
- Run this command from the login node (e.g., `login3`):
  ```bash
  tail -f my_job.log
  ```
- `tail -f` shows the last few lines of the file and updates as new output is written. Press `Ctrl+C` to stop watching.
- Similarly, if there are errors, check `my_job.err` with:
  ```bash
  tail -f my_job.err
  ```

#### 2. Add Progress Updates to Your Python Script
If `test.py` isn’t printing anything useful, you’ll need to modify it (or the script you actually want to run) to output progress. Here are two simple ways:

- **Using Print Statements**:
  Add `print()` calls in your script to show what’s happening. For example:
  ```python
  # test.py
  for i in range(100):
      print(f"Processing step {i+1}/100")
      # Your code here
  ```
  These messages will go to `my_job.log`, which you can monitor with `tail -f`.

- **Using the Logging Module** (Recommended):
  Python’s `logging` module lets you write detailed progress to a separate file. Here’s an example:
  ```python
  # test.py
  import logging

  # Set up logging to a file
  logging.basicConfig(filename='experiment.log', level=logging.INFO)
  logger = logging.getLogger()

  for i in range(100):
      logger.info(f"Processing step {i+1}/100")
      # Your code here
  ```
  This creates an `experiment.log` file in your `/home/jimmy.silva/workspaces/ATHENA/athena` directory. Monitor it with:
  ```bash
  tail -f experiment.log
  ```

#### 3. Check SLURM Job Status
To see if your job is still running, pending, or finished, use:
```bash
squeue -j 705934
```
Replace `705934` with your job ID (from the `Submitted batch job 705934` message). This shows the job’s status (e.g., `R` for running, `PD` for pending).

---

### Are You Running the Right Script?
Your `run_sbatch.sh` currently runs `test.py`, but the instructions mention executing `main.py` (likely in `my_experiments/`). If `test.py` is just a placeholder and your actual work is in, say, `my_experiments/main.py`, you should update `run_sbatch.sh`. Edit it like this:

```bash
#!/bin/bash
#SBATCH --partition=gpulongd
#SBATCH --account=asml-gpu
#SBATCH --job-name=go_athena
#SBATCH --time=520:00:00

echo "Job ID: $SLURM_JOB_ID"
echo "Running on node: $(hostname)"
echo "Allocated GPU(s): $CUDA_VISIBLE_DEVICES"

# Run your actual script
singularity exec --nv Singularity.sif python my_experiments/main.py
```

Then resubmit the job:
```bash
sbatch --output=my_job.log --error=my_job.err run_sbatch.sh
```

Make sure `main.py` (or whatever script you use) has print statements or logging to show progress.

---

### Testing Before Submitting a Long Job
Since you’re new to this, it’s a good idea to test your setup interactively before running a long job. Use the `srun` command you tried:
```bash
srun --partition gpulongd --account asml-gpu --job-name=go_athena --time 120:00:00 --pty bash
```
This gives you a shell on a compute node. Inside it:
1. Run your script manually:
   ```bash
   singularity exec --nv Singularity.sif python my_experiments/main.py
   ```
2. Watch the output directly in your terminal.
3. Check if it works as expected (e.g., accesses `datasets/`, prints progress, etc.).

If everything looks good, you can confidently submit the job with `sbatch`.

---

### Ensuring Everything Works Correctly
Here are a few things to double-check as a beginner:

#### 1. Container Setup
- Your `Singularity.sif` is built from `Singularity.def`. If you add packages to `requirements.txt`, rebuild the container:
  ```bash
  singularity build Singularity.sif Singularity.def
  ```
- Since your scripts (e.g., `test.py`, `my_experiments/main.py`) and `datasets/` are in your working directory, they’re automatically available inside the container (Singularity mounts the current directory by default).

#### 2. File Paths
- If your script reads from `datasets/`, ensure it uses the correct path. For example:
  ```python
  with open('datasets/myfile.txt', 'r') as f:
      data = f.read()
  ```
- This works because `/home/jimmy.silva/workspaces/ATHENA/athena` is mounted into the container.

#### 3. Output Files
- If your script saves files (e.g., model checkpoints), they’ll appear in your working directory unless you specify another path. Ensure the script creates any needed directories:
  ```python
  import os
  os.makedirs('outputs', exist_ok=True)
  ```

---

### Putting It All Together
Here’s a plan to monitor your job’s progress:
1. **Edit Your Script**: Add `print()` or `logging` to `test.py` or `my_experiments/main.py` to show progress.
2. **Update run_sbatch.sh**: Point it to the correct script (e.g., `python my_experiments/main.py`).
3. **Test Interactively**:
   ```bash
   srun --partition gpulongd --account asml-gpu --job-name=go_athena --time 120:00:00 --pty bash
   singularity exec --nv Singularity.sif python my_experiments/main.py
   ```
4. **Submit the Job**:
   ```bash
   sbatch --output=my_job.log --error=my_job.err run_sbatch.sh
   ```
5. **Monitor Progress**:
   - `tail -f my_job.log` for print output.
   - `tail -f experiment.log` if you used logging.
   - `squeue -j <job_id>` to check job status.

---

### Extra Tips for Beginners
- **Long-Running Jobs**: If your job takes hours, add periodic checkpoints (e.g., save a model every 10 iterations) so you can check progress via saved files.
- **Debugging**: If something fails, check `my_job.err` for error messages.
- **Time Limits**: The `520:00:00` in `run_sbatch.sh` is ~21 days. Adjust it based on your needs and cluster policies.
- **Copy folders**: If you want to copy folders from local to the CLUSTER, you can do something like this: 
```bash
scp -p 5001 -r /<folder> marc.freir@dragoncluster-login3.shawaska.org.uk:/home/marc.freir/workspaces/ATHENA/athena/datasets/
```
Or
```bash
rsync -avzP -p 5001 -r /<folder> marc.freir@dragoncluster-login3.shawaska.org.uk:/home/marc.freir/workspaces/ATHENA/athena/datasets/
```
- **Copy files**: If you want to copy folders from local to the CLUSTER, you can do something like this: 
```bash
scp -p 5001 /<file> marc.freir@dragoncluster-login3.shawaska.org.uk:/home/marc.freir/workspaces/ATHENA/athena/datasets/
```
Or
```bash
rsync -avzP -p 5001 /<file> marc.freir@dragoncluster-login3.shawaska.org.uk:/home/marc.freir/workspaces/ATHENA/athena/datasets/
```
P.S.: to copy folders or files from remote to remote (i.e., already inside the CLUSTER, just use `cp` instead of `scp`).

---

### Tips for Using `tmux` on the Cluster

Since you’re working on a cluster (like DRAGON), `tmux` is a fantastic tool to manage your sessions. It’s especially useful because it keeps your work running even if your SSH connection drops (e.g., due to a network issue). Your `Singularity.def` already includes `tmux`, so it’s available in your container! Here are some beginner-friendly tips:

#### 1. Start a `tmux` Session
- On the login node or inside an interactive SLURM session (via `srun ... --pty bash`), run:
  ```bash
  tmux
  ```
- This opens a new terminal session that persists even if you disconnect.

#### 2. Run Your Job in `tmux`
- Inside the `tmux` session, start your script or monitor logs:
  ```bash
  singularity exec --nv Singularity.sif python my_experiments/main.py
  ```
  OR
  ```bash
  tail -f my_job.log
  ```
- To leave the session running in the background, detach from it (see below).

#### 3. Detach and Reattach
- **Detach**: Press `Ctrl+B`, then `D`. This exits `tmux` without stopping your job.
- **List Sessions**: Later, run `tmux list-sessions` (or `tmux ls`) to see all active sessions.
- **Reattach**: Run `tmux attach-session -t 0` (replace `0` with the session number from `tmux ls`).

#### 4. Use `tmux` with SLURM
- Start an interactive SLURM session:
  ```bash
  srun --partition gpulongd --account asml-gpu --job-name=go_athena --time 120:00:00 --pty bash
  ```
- Inside the compute node, launch `tmux`:
  ```bash
  tmux
  ```
- Run your container commands (e.g., `singularity exec ...`). Detach with `Ctrl+B, D` to keep it going.

#### 5. Split Windows for Multitasking
- **Vertical Split**: Press `Ctrl+B`, then `"`. This splits the screen horizontally.
- **Horizontal Split**: Press `Ctrl+B`, then `%`. This splits vertically.
- **Switch Panes**: Use `Ctrl+B`, then arrow keys.
- Example: Monitor `my_job.log` in one pane (`tail -f my_job.log`) and `my_job.err` in another (`tail -f my_job.err`).

#### 6. Kill a `tmux` Session
- If you’re done, reattach (`tmux attach-session -t 0`), then type `exit` or press `Ctrl+D`.
- Or, from outside: `tmux kill-session -t 0` (replace `0` with the session number).

#### 7. Why Use `tmux`?
- **Persistence**: If your SSH connection drops, your job or monitoring keeps running.
- **Flexibility**: Run multiple tasks (e.g., script execution, log monitoring) in one session.
- **Cluster-Friendly**: Works well with SLURM for interactive debugging.

#### Example Workflow
1. Start an interactive SLURM session:
   ```bash
   srun --partition gpulongd --account asml-gpu --job-name=go_athena --time 120:00:00 --pty bash
   ```
2. Launch `tmux`:
   ```bash
   tmux
   ```
3. Run your script:
   ```bash
   singularity exec --nv Singularity.sif python my_experiments/main.py
   ```
4. Detach (`Ctrl+B, D`), log out, and check back later by reattaching (`tmux attach-session -t 0`).

`tmux` is a lifesaver for cluster work—give it a try 🚀
