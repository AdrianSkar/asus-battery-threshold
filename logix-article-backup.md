[![limit asus battery charging linux](https://www.linuxuprising.com/ezoimgfmt/1.bp.blogspot.com/-O6tK-krwzUo/YC6gCLr3_iI/AAAAAAAAFPA/4rYjjWc44lMJdOZd50hMCINlFcxr5AKtwCLcBGAsYHQ/s640/asus-battery-charge-threshold-linux.png?ezimgfmt=rs%3Adevice%2Frscb273-1 "limit asus battery charging linux")](https://1.bp.blogspot.com/-O6tK-krwzUo/YC6gCLr3_iI/AAAAAAAAFPA/4rYjjWc44lMJdOZd50hMCINlFcxr5AKtwCLcBGAsYHQ/s1600/asus-battery-charge-threshold-linux.png)

**Newer ASUS laptops support limiting the battery charge level, which helps prolong battery life. This article explains how to set a battery charge threshold for ASUS laptops on Linux.**

Battery lifespan is affected by age, high temperatures, the number of charge cycles, and the amount of time at full charge. A battery charge threshold reduces the amount of time at full charge (100%), and thus improves battery health / life.

**ASUS laptops support setting a charge threshold [starting with](https://github.com/torvalds/linux/commit/d507a54f5865d8dcbdd16c66a1a2da15640878ca) Linux 5.4**. The kernel WMI method to set the charge threshold does not provide a way to specify a battery, assuming it's the first battery (`BAT0`). However, for some newer ASUS laptops, the primary battery is not called `BAT0`, but `BATT` (e.g. Zenbook UM431DA) and `BAT1` (e.g. ASUS TUF Gaming FX706II). \[Edit\] And There's also BATC.

So while ASUS laptops support limiting battery charging starting with Linux 5.4, that's only for laptops having `BAT0`. **For ASUS laptops using `BATT` as the primary battery name, you'll need [kernel 5.7](https://github.com/torvalds/linux/commit/6b3586d45bba14f6912f37488090c37a3710e7b4), while for `BAT1` you'll need the [5.8 kernel](https://github.com/torvalds/linux/commit/9a33e375d98ece5ea40c576eabd3257acb90c509)** (in the instructions below you'll see exactly how to check the battery name). **\[Edit\] For ASUS laptops using BATC battery name, you'll need to use [Linux 5.9](https://github.com/torvalds/linux/commit/1d2dd379bd99ee4356ae4552fd1b8e43c7ca02cd) or newer.**

Also, **not all ASUS laptops support setting a battery charge threshold so depending on your ASUS laptop model, this may or may not work for you; there's no list of supported devices that I could find.**

It's important to mention that **the kernel WMI method of setting the battery charge threshold for ASUS notebooks can only set the stop value (`charge_control_end_threshold`)** (it can't also set the start threshold). Also, with AC connected, if the battery level is higher than the charge stop threshold, it will not be discharged to the stop threshold.

And another note. With my ASUS ZenBook 14 UX433FAC running Ubuntu 20.04 with GNOME Shell, when limiting battery charging while the battery level is equal or greater than the charge threshold, and then connect the laptop to AC, the battery indicator from the top panel changes from the time remaining until the battery discharges to the time remaining until the battery is charged. This happens even though the battery is not charging. After a while (so this is not instant when you connect your laptop to AC), the battery indicator changes to say "Not charging", as it should.

**Besides ASUS, some Lenovo and Huawei (with the latter getting support with [Linux 5.5](https://github.com/torvalds/linux/commit/355a070b09ab1f29f36447c91cde3e6fd07775e0)) laptops also have support for limiting battery charging. But since I only own an ASUS laptop and I can't test it on other devices, this guide is for ASUS only.** Lenovo has had support for this for quite a while, and [TLP](https://www.linuxuprising.com/2020/02/tlp-13-linux-laptop-battery-extender.html) has support for setting this built-in (only for IBM/Lenovo ThinkPads). As a side note, here's a [GUI for TLP](https://www.linuxuprising.com/2018/09/tlpui-is-graphical-user-interface-for.html) to easily configure it, in case you're not using it already.

**_You might also like: [auto-cpufreq Is A CPU Speed And Power Optimizer For Linux](https://www.linuxuprising.com/2020/01/auto-cpufreq-is-new-cpu-speed-and-power.html)_**

**1\. Find out your ASUS' laptop battery name.**

Let's start by figuring out the battery name for your ASUS laptop. This can be done by using the following command:

```
ls /sys/class/power_supply
```

This command should output something like this:

```
AC0  BAT0
```

In this example (from my ASUS notebook), the name of the battery is `BAT0`, but like I mentioned above, for you it may also be `BAT1` or `BATT`, these being the only supported battery names by the kernel for ASUS laptops.

**2\. Create a systemd service to set the battery charge stop threshold on boot.**

Before creating the systemd service, check if your laptop actually has `charge_control_end_threshold` in `/sys/class/power_supply/BAT*` (without it, this won't work):

```
ls /sys/class/power_supply/BAT*/charge_control_end_threshold
```

If this command returns the path to `charge_control_end_threshold`, then your ASUS notebook supports limiting battery charging. If the command returns an error, saying there's no such file or directory, then your laptop doesn't support setting a charge threshold.

If your ASUS laptop has this file, we can continue. Create a file which we'll call `battery-charge-threshold.service` in `/etc/systemd/system`.

You can open this file with your default console text editor using:

```
sudo editor /etc/systemd/system/battery-charge-threshold.service
```

Or use Gedit or whatever graphical editor you want to use (e.g. for Gedit to [open this file as root](https://www.linuxuprising.com/2018/04/gksu-removed-from-ubuntu-heres.html): `gedit admin:///etc/systemd/system/battery-charge-threshold.service`)

In this file you'll need to paste the following:

```
[Unit]Description=Set the battery charge thresholdAfter=multi-user.targetStartLimitBurst=0[Service]Type=oneshotRestart=on-failureExecStart=/bin/bash -c 'echo CHARGE_STOP_THRESHOLD > /sys/class/power_supply/BATTERY_NAME/charge_control_end_threshold'[Install]WantedBy=multi-user.target
```

Here, change `BATTERY_NAME` with the name of the battery (`BAT0`, `BAT1` or `BATT`), and `CHARGE_STOP_THRESHOLD` with the battery charge stop threshold you want to use (ranging between 1 and 100). Note that [I've read](https://github.com/linrunner/TLP/issues/528#issuecomment-686713034) that one user couldn't set the charge threshold to any value, but only to 60, 80 and 100.

From what I've read, for best battery lifespan when the laptop is connected to AC most of the time, set the battery charge stop threshold at around 50 or 60. If the battery is used somewhat frequently, set the battery charge stop threshold at about 90.

**3\. Enable and start the battery-charge-threshold systemd service.**

Now let's enable and start the newly created battery-charge-threshold systemd service:

```
sudo systemctl enable battery-charge-threshold.servicesudo systemctl start battery-charge-threshold.service
```

_With systemd 220, it's possible to enable and start a service directly using `systemctl enable --now`, but I prefer to use 2 commands in case some readers use an older systemd version._

**If you want to change the battery charge stop threshold level**, you'll need to edit the `/etc/systemd/system/battery-charge-threshold.service` file, and change the number from the `ExecStart` line (after `echo`) to the new value you want to use, then reload systemd (because the file contents have changed) and restart the systemd service using the following commands:

```
sudo systemctl daemon-reloadsudo systemctl restart battery-charge-threshold.service
```

**4\. Verify that the battery charge stop threshold is working.**

If your ASUS laptop supports it, the battery charging limit should now be set to the value you've used in step 2.

You can check this by charging your laptop to the threshold set in `battery-charge-threshold.service`, and then use this command:

```
cat /sys/class/power_supply/BATTERY_NAME/status
```

Replace `BATTERY_NAME` with the name of the battery, as explained under step 1.

If the battery charge stop threshold is working, the command should show the following output:

```
Not Charging
```

If it says "Discharging", make sure your ASUS laptop is actually on AC power, and not running on battery. However, if it says "Charging", well... then your laptop is charging past the charge stop threshold, so this is not working for you, either because your ASUS laptop doesn't support it (which is weird if you have `charge_control_end_threshold` as mentioned in step 2), you're using a Linux version that's too old for limiting battery charging on your ASUS notebook, or because of human error 😁️.

**Extra: In case you don't use systemd, you can also do this by using cron, by running `sudo crontab -e` and then pasting the following line (this is a single line, triple-click the line to select the whole line), although this is not reliable in all cases from what I've read (I'm not sure why):**

```
@reboot echo CHARGE_STOP_THRESHOLD > /sys/class/power_supply/BATTERY_NAME/charge_control_end_threshold
```

Replacing `CHARGE_STOP_THRESHOLD` with the battery charge stop threshold you want to use and `BATTERY_NAME` with the battery name as seen in step 1.

Why use a systemd service or a cron job? According to u/esrevartb, from whom I've adapted these instructions, "_it seems the udev rule isn't working either because the battery sysfs path isn't yet initialized when the rule gets applied, or because this specific charge\_control\_end\_threshold attribute cannot be modified this way_".

**\[\[Edit\] To easily set a charge threshold for ASUS laptops (automatic setup of the systemd service and the ability to change the charge threshold using a command), as well as check the current charging threshold, see [bat](https://www.linuxuprising.com/2021/06/easily-set-charging-thresholds-for-asus.html).  
**

**\[\[Edit 2\]\] [TLP 1.4.0](https://github.com/linrunner/TLP/releases/tag/1.4.0) has also added support for limiting battery charging on ASUS laptops.**

**_Laptop battery-related: [Bwall Is An Animated Battery Wallpaper For Linux (Bash Script)](https://www.linuxuprising.com/2021/02/bwall-is-animated-battery-wallpaper-for.html)_**

via [r/linuxhardware](https://www.reddit.com/r/linuxhardware/comments/g8kpee/psa_kernel_54_added_the_ability_to_set_a_battery/) (thanks u/esrevartb)