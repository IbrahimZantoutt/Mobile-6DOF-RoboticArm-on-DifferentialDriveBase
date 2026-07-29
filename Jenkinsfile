pipeline{
    agent { docker{ image 'mobiarm'  } }
    stages{
        stage("Build"){
            steps{
                sh '''#!/bin/bash
                    source /opt/ros/humble/setup.bash
                    colcon build
                '''
            }
        }
    }

}