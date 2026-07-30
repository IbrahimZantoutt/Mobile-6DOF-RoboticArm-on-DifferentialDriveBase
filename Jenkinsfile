
pipeline {
    agent none
    parameters{
        choice(name:"TargetStage",choices:["build","pytest","both"],description:"choose which stage tp run")
    }
    stages {
        stage("parrallel build"){
            parallel{
                stage("build") {
                    when{expression{params.TargetStage == "build" || params.TargetStage == "both"}}
                    agent { docker { image 'mobiarm' } }
                    steps {
                        sh '''#!/bin/bash
                            source /opt/ros/humble/setup.bash
                            colcon build
                        '''
                    }
                }
                stage("pytest") {
                    when{expression{params.TargetStage == "pytest" || params.TargetStage == "both"}}
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
