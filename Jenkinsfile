
pipeline {
    agent none
    stages {
        stage("check branch"){
            when{branch 'main'}
            steps{
                sh'echo "in main branch"'
            }
        }
        stage("parrallel build"){
            parallel{
                stage("build") {
                    agent { docker { image 'mobiarm' } }
                    steps {
                        sh '''#!/bin/bash
                            source /opt/ros/humble/setup.bash
                            colcon build
                        '''
                    }
                }
                stage("pytest") {
                    agent { docker { image 'python:3.12' } }
                    steps {
                        sh 'echo "testing python"'
                    }
                }
            }
        }
       
    }
    post {
        always { echo "ran the pipeline" }
        success { echo "pipeline succeeded" }
        failure { echo "pipeline failed" }
    }
}
