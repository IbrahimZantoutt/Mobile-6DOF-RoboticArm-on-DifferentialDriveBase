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

COPY src src

RUN apt-get update && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/humble/setup.sh && colcon build