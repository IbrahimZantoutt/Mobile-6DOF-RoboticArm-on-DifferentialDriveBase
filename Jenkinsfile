@Library('Global-Shared-Lib') _

def generateTag(branch,buildNum){
    return "${branch}-${buildNum}"
}

pipeline{
    agent none
    parameters{
        choice(name:"ActionType",choices:["noPush","push"], description:"push or dont push the image")
    }
    stages{
        stage("announce"){
            agent any
            steps{
                sh'echo "branch: $BRANCH_NAME"'
            }
        }
        stage("build image"){
            agent any
            when{
                changeset 'Dockerfile'
            }
            options{
                timeout(time:20,unit:"MINUTES")
            }
            steps{
                sh'docker build -t mobiarm .'
            }
        }
        stage("parallel build stage"){
            parallel{
                stage("ros2 stage"){
                    agent{docker{image 'mobiarm'}}
                    steps{
                        sh'''#!/bin/bash
                        source /opt/ros/humble/setup.bash
                        colcon build
                        '''

                        archiveArtifacts artifacts: "build/**", allowEmptyArchive:true
                    }
                }
                stage("py stage"){
                    agent{docker{image 'python:3.12'}}
                    steps{
                        script{
                            try{
                                sh '''
                                mkdir -p report
                                cat > report/results.xml << 'EOF'
                                <testsuite tests="2" failures="1">
                                    <testcase name="test_one" classname="fake.tests">
                                    </testcase>
                                    <testcase name="test_two" classname="fake.tests">
                                        <failure message="simulated failure">Expected true, got false</failure>
                                    </testcase>
                                </testsuite>
                                EOF
                                '''
                            }
                            catch (Exception e){
                                echo "caught exception while writing file: ${e.getMessage()}"
                                currentBuild.result = "UNSTABLE"
                            }
                        }
                        
                        junit "report/results.xml"

                        archiveArtifacts artifacts: "report/**", allowEmptyArchive:true

                        script{
                            def map = [vision_node: true, arm_controller: false, nav_stack: true]
                            def mapFilt = map.findAll{key,value -> value == true}
                            echo mapFilt
                        }
                    }

                }
            }
        }
        stage("push stage"){
            agent any
            when{
                allOf{
                    branch 'main'
                    expression{params.ActionType == "push"}
                }
            }
            steps{
                script{
                    env.IMAGE_TAG = generateTag(env.BRANCH_NAME,env.BUILD_NUMBER)
                }
                TagPushDockerImage("mobiarm",env.IMAGE_TAG,"tokenDocker")
            }
        }
    }
    post{
        always{echo "running pipeline"}
        failure{echo "pipeline failure"}
        success{echo "pipeline success"}
    }
}