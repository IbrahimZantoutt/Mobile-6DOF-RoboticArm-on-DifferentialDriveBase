pipeline{
    agent { docker{ image 'mobiarm'  } }
    stages{
        stage("Build"){
            steps{
                sh '''
                    source /opt/ros/humble/setup.bash && colcon build
                '''
            }
        }
    }

}