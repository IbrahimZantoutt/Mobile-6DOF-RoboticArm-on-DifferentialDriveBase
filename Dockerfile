FROM ros:humble

WORKDIR /MobiArm

RUN apt-get update && \
    apt-get install -y \
      ros-humble-moveit \
      ros-humble-gazebo-ros-pkgs \
      ros-humble-gazebo-ros2-control \
      ros-humble-ros2-controllers \
      ros-humble-navigation2 \
      ros-humble-nav2-bringup \
      ros-humble-slam-toolbox \
      ros-humble-rviz2 \
      libopencv-dev && \
    rm -rf /var/lib/apt/lists/*

# static-analysis toolchain (static_test stage)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cppcheck \
      python3-flake8 \
      libxml2-utils \
      curl ca-certificates && \
    curl -fsSL -o /usr/local/bin/hadolint \
      https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 && \
    chmod +x /usr/local/bin/hadolint && \
    rm -rf /var/lib/apt/lists/*

COPY src src

RUN apt-get update && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/humble/setup.sh && colcon build