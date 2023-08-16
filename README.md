# Quickly change charging threshold on specific Asus laptop models in Linux

Following Logix's article on _[How to limit battery charging on Asus laptops on Linux](https://www.linuxuprising.com/2021/02/how-to-limit-battery-charging-set.html)_, specifically/likely on ZenBook models, I created this repo in order to share and save instructions on how to easily change the threshold with simple commands rather than having to change the `.service` file each time. 

Provided you followed the article instructions and have a working service that 
follows the charge limit (some Arch distros have a UI setting to set an upper limit/threshold but won't work as of yet) you can follow these steps and change values just using `alias NUMBER` to change this threshold:

### 1. Create/copy a script file that modifies the threshold
Create or copy [change-battery-threshold.sh](./change-battery-threshold.sh) to automate the process of changing `battery-charge-threshold.service`'s threshold value. Make sure to use the correct battery name in place of `BATT` at line `13`.

### 2. Make the file executable
Eg: `chmod +x change-battery-threshold.sh`.

### 3. Create an alias for  your command
Choose an alias like `batteryMax` and add the alias for your system replacing `PATH` to follow your file location:
- bash: `alias batteryMax='/PATH/change-battery-threshold.sh'
` + reload your `.bashrc` with `source ~/.bashrc`
- fish: modify `~/.config/fish/config.fish` and add:
	```bash
	# Update battery charging threshold
	alias batteryMax="/PATH/battery-change-threshold.sh"
	```


---
Resources:
- 📁[Local/backup article](./logix-article-backup.md)
- 📁[.service file example](./battery-threshold.service)