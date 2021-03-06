#!/usr/bin/bash

if [ ! -f "./installer/boot_finish" ]; then
  echo "Installing fonts..."
  mount -o rw,remount /system
  cp -f ./installer/fonts/NanumGothic* /system/fonts/
  cp -f ./installer/fonts/opensans_* ./selfdrive/assets/fonts/
  cp -f ./installer/fonts/fonts.xml /system/etc/fonts.xml
  chmod 644 /system/etc/fonts.xml
  chmod 644 /system/fonts/NanumGothic*
  cp -f ./installer/bootanimation.zip /system/media/
  cp -f ./installer/spinner ./selfdrive/ui/qt/
  sed -i 's/self._AWARENESS_TIME = 35/self._AWARENESS_TIME = 10800/' ./selfdrive/monitoring/driver_monitor.py
  sed -i 's/self._DISTRACTED_TIME = 11/self._DISTRACTED_TIME = 7200/' ./selfdrive/monitoring/driver_monitor.py
  sed -i 's/self.face_detected = False/self.face_detected = True/' ./selfdrive/monitoring/driver_monitor.py
  sed -i 's/self.face_detected = driver/self.face_detected = True # driver/' ./selfdrive/monitoring/driver_monitor.py
  sed -i 's/DAYS_NO_CONNECTIVITY_MAX = 7/DAYS_NO_CONNECTIVITY_MAX = 999/' ./selfdrive/thermald/thermald.py
  sed -i 's/DAYS_NO_CONNECTIVITY_PROMPT = 4/DAYS_NO_CONNECTIVITY_PROMPT = 999/' ./selfdrive/thermald/thermald.py
  chmod 700 ./t.sh
  chmod 744 /system/media/bootanimation.zip
  chmod 700 ./selfdrive/ui/qt/spinner
  chmod 700 ./scripts/*.sh
  chmod 700 ./installer/updater/*.json
  sed -i -e 's/\r$//' ./*.py
  sed -i -e 's/\r$//' ./selfdrive/*.py
  sed -i -e 's/\r$//' ./selfdrive/manager/*.py
  sed -i -e 's/\r$//' ./selfdrive/car/*.py
  sed -i -e 's/\r$//' ./selfdrive/ui/*.cc
  sed -i -e 's/\r$//' ./selfdrive/ui/*.h
  sed -i -e 's/\r$//' ./selfdrive/controls/*.py
  sed -i -e 's/\r$//' ./selfdrive/controls/lib/*.py
  sed -i -e 's/\r$//' ./selfdrive/locationd/models/*.py
  sed -i -e 's/\r$//' ./cereal/*.py
  sed -i -e 's/\r$//' ./cereal/*.capnp
  sed -i -e 's/\r$//' ./selfdrive/car/gm/*.py
  sed -i -e 's/\r$//' ./selfdrive/ui/qt/*.cc
  sed -i -e 's/\r$//' ./selfdrive/ui/qt/*.h
  sed -i -e 's/\r$//' ./selfdrive/ui/qt/offroad/*.cc
  sed -i -e 's/\r$//' ./selfdrive/ui/qt/widgets/*.cc
  sed -i -e 's/\r$//' ./selfdrive/ui/qt/offroad/*.h
  sed -i -e 's/\r$//' ./selfdrive/ui/qt/widgets/*.h
  sed -i -e 's/\r$//' ./selfdrive/controls/lib/lead_mpc_lib/*.py
  sed -i -e 's/\r$//' ./selfdrive/controls/lib/lead_mpc_lib/lib_mpc_export/*.h
  sed -i -e 's/\r$//' ./selfdrive/controls/lib/lead_mpc_lib/*.c
  sed -i -e 's/\r$//' ./selfdrive/controls/lib/lead_mpc_lib/lib_mpc_export/*.c
  sed -i -e 's/\r$//' ./selfdrive/boardd/*.cc
  sed -i -e 's/\r$//' ./selfdrive/boardd/*.pyx
  sed -i -e 's/\r$//' ./selfdrive/boardd/*.h
  sed -i -e 's/\r$//' ./selfdrive/boardd/*.py
  sed -i -e 's/\r$//' ./selfdrive/camerad/cameras/*.h
  sed -i -e 's/\r$//' ./selfdrive/camerad/cameras/*.cc
  sed -i -e 's/\r$//' ./selfdrive/camerad/snapshot/*.py
  sed -i -e 's/\r$//' ./selfdrive/camerad/*.cc
  sed -i -e 's/\r$//' ./selfdrive/thermald/*.py
  sed -i -e 's/\r$//' ./selfdrive/athena/*.py
  sed -i -e 's/\r$//' ./installer/updater/*.json
  sed -i -e 's/\r$//' ./scripts/*.sh
  sed -i -e 's/\r$//' ./common/*.py
  sed -i -e 's/\r$//' ./common/*.pyx
  sed -i -e 's/\r$//' ./common/*.pxd
  sed -i -e 's/\r$//' ./scripts/oneplus_update_neos.sh
  sed -i -e 's/\r$//' ./launch_env.sh
  sed -i -e 's/\r$//' ./launch_openpilot.sh
  sed -i -e 's/\r$//' ./Jenkinsfile
  sed -i -e 's/\r$//' ./SConstruct
  sed -i -e 's/\r$//' ./t.sh
  sed -i -e 's/\r$//' ./installer/updater/*.json
  touch ./installer/boot_finish

elif [ "$(getprop persist.sys.locale)" != "ko-KR" ]; then

  setprop persist.sys.locale ko-KR
  setprop persist.sys.language ko
  setprop persist.sys.country KR
  setprop persist.sys.timezone Asia/Seoul

  sleep 2
  reboot
else
  chmod 644 /data/openpilot/installer/boot_finish
  mount -o ro,remount /system
fi

if [ -z "$BASEDIR" ]; then
  BASEDIR="/data/openpilot"
fi

source "$BASEDIR/launch_env.sh"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

function two_init {

  # set IO scheduler
  setprop sys.io.scheduler noop
  for f in /sys/block/*/queue/scheduler; do
    echo noop > $f
  done

  # *** shield cores 2-3 ***

  # TODO: should we enable this?
  # offline cores 2-3 to force recurring timers onto the other cores
  #echo 0 > /sys/devices/system/cpu/cpu2/online
  #echo 0 > /sys/devices/system/cpu/cpu3/online
  #echo 1 > /sys/devices/system/cpu/cpu2/online
  #echo 1 > /sys/devices/system/cpu/cpu3/online

  # android gets two cores
  echo 0-1 > /dev/cpuset/background/cpus
  echo 0-1 > /dev/cpuset/system-background/cpus
  echo 0-1 > /dev/cpuset/foreground/cpus
  echo 0-1 > /dev/cpuset/foreground/boost/cpus
  echo 0-1 > /dev/cpuset/android/cpus

  # openpilot gets all the cores
  echo 0-3 > /dev/cpuset/app/cpus

  # mask off 2-3 from RPS and XPS - Receive/Transmit Packet Steering
  echo 3 | tee  /sys/class/net/*/queues/*/rps_cpus
  echo 3 | tee  /sys/class/net/*/queues/*/xps_cpus

  # *** set up governors ***

  # +50mW offroad, +500mW onroad for 30% more RAM bandwidth
  echo "performance" > /sys/class/devfreq/soc:qcom,cpubw/governor
  echo 1056000 > /sys/class/devfreq/soc:qcom,m4m/max_freq
  echo "performance" > /sys/class/devfreq/soc:qcom,m4m/governor

  # unclear if these help, but they don't seem to hurt
  echo "performance" > /sys/class/devfreq/soc:qcom,memlat-cpu0/governor
  echo "performance" > /sys/class/devfreq/soc:qcom,memlat-cpu2/governor

  # GPU
  echo "performance" > /sys/class/devfreq/b00000.qcom,kgsl-3d0/governor

  # /sys/class/devfreq/soc:qcom,mincpubw is the only one left at "powersave"
  # it seems to gain nothing but a wasted 500mW

  # *** set up IRQ affinities ***

  # Collect RIL and other possibly long-running I/O interrupts onto CPU 1
  echo 1 > /proc/irq/78/smp_affinity_list # qcom,smd-modem (LTE radio)
  echo 1 > /proc/irq/33/smp_affinity_list # ufshcd (flash storage)
  echo 1 > /proc/irq/35/smp_affinity_list # wifi (wlan_pci)
  echo 1 > /proc/irq/6/smp_affinity_list  # MDSS

  # USB traffic needs realtime handling on cpu 3
  [ -d "/proc/irq/733" ] && echo 3 > /proc/irq/733/smp_affinity_list

  # GPU and camera get cpu 2
  CAM_IRQS="177 178 179 180 181 182 183 184 185 186 192"
  for irq in $CAM_IRQS; do
    echo 2 > /proc/irq/$irq/smp_affinity_list
  done
  echo 2 > /proc/irq/193/smp_affinity_list # GPU

  # give GPU threads RT priority
  for pid in $(pgrep "kgsl"); do
    chrt -f -p 52 $pid
  done

  # the flippening!
  LD_LIBRARY_PATH="" content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:1

  # disable bluetooth
  service call bluetooth_manager 8

  # wifi scan
  wpa_cli IFNAME=wlan0 SCAN

  # Check for NEOS update
  if [ $(< /VERSION) != "$REQUIRED_NEOS_VERSION" ]; then
    if [ -f "$DIR/scripts/continue.sh" ]; then
      cp "$DIR/scripts/continue.sh" "/data/data/com.termux/files/continue.sh"
    fi

    if [ ! -f "$BASEDIR/prebuilt" ]; then
      # Clean old build products, but preserve the scons cache
      cd $DIR
      git clean -xdf
      git submodule foreach --recursive git clean -xdf
    fi

    "$DIR/installer/updater/updater" "file://$DIR/installer/updater/update.json"
  fi
}

function tici_init {
  # wait longer for weston to come up
  if [ -f "$BASEDIR/prebuilt" ]; then
    sleep 3
  fi

  sudo su -c 'echo "performance" > /sys/class/devfreq/soc:qcom,memlat-cpu0/governor'
  sudo su -c 'echo "performance" > /sys/class/devfreq/soc:qcom,memlat-cpu4/governor'
  nmcli connection modify --temporary lte gsm.auto-config yes
  nmcli connection modify --temporary lte gsm.home-only yes

  # set success flag for current boot slot
  sudo abctl --set_success

  # Check if AGNOS update is required
  if [ $(< /VERSION) != "$AGNOS_VERSION" ]; then
    AGNOS_PY="$DIR/selfdrive/hardware/tici/agnos.py"
    MANIFEST="$DIR/selfdrive/hardware/tici/agnos.json"
    if $AGNOS_PY --verify $MANIFEST; then
      sudo reboot
    fi
    $DIR/selfdrive/hardware/tici/updater $AGNOS_PY $MANIFEST
  fi
}

function launch {
  # Remove orphaned git lock if it exists on boot
  [ -f "$DIR/.git/index.lock" ] && rm -f $DIR/.git/index.lock

  # Pull time from panda
  $DIR/selfdrive/boardd/set_time.py

  # Check to see if there's a valid overlay-based update available. Conditions
  # are as follows:
  #
  # 1. The BASEDIR init file has to exist, with a newer modtime than anything in
  #    the BASEDIR Git repo. This checks for local development work or the user
  #    switching branches/forks, which should not be overwritten.
  # 2. The FINALIZED consistent file has to exist, indicating there's an update
  #    that completed successfully and synced to disk.

  if [ -f "${BASEDIR}/.overlay_init" ]; then
    find ${BASEDIR}/.git -newer ${BASEDIR}/.overlay_init | grep -q '.' 2> /dev/null
    if [ $? -eq 0 ]; then
      echo "${BASEDIR} has been modified, skipping overlay update installation"
    else
      if [ -f "${STAGING_ROOT}/finalized/.overlay_consistent" ]; then
        if [ ! -d /data/safe_staging/old_openpilot ]; then
          echo "Valid overlay update found, installing"
          LAUNCHER_LOCATION="${BASH_SOURCE[0]}"

          mv $BASEDIR /data/safe_staging/old_openpilot
          mv "${STAGING_ROOT}/finalized" $BASEDIR
          cd $BASEDIR

          # Partial mitigation for symlink-related filesystem corruption
          # Ensure all files match the repo versions after update
          git reset --hard
          git submodule foreach --recursive git reset --hard

          echo "Restarting launch script ${LAUNCHER_LOCATION}"
          unset REQUIRED_NEOS_VERSION
          unset AGNOS_VERSION
          exec "${LAUNCHER_LOCATION}"
        else
          echo "openpilot backup found, not updating"
          # TODO: restore backup? This means the updater didn't start after swapping
        fi
      fi
    fi
  fi

  # handle pythonpath
  ln -sfn $(pwd) /data/pythonpath
  export PYTHONPATH="$PWD:$PWD/pyextra"

  # hardware specific init
  if [ -f /EON ]; then
    two_init
  elif [ -f /TICI ]; then
    tici_init
  fi

  # write tmux scrollback to a file
  tmux capture-pane -pq -S-1000 > /tmp/launch_log

  # start manager
  cd selfdrive/manager
  ./build.py && ./manager.py

  # if broken, keep on screen error
  while true; do sleep 1; done
}

launch
