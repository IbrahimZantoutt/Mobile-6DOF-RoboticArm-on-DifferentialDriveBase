pipeline{
    agent { docker{ image 'mobiarm'  } }
    stages{
        stage("Build"){
            steps{
                sh '''
                    . /opt/ros/humble/setup.bash
                    colcon build
                '''
            }
        }
    }

}