def call(String envName){
    def status = sh(
        script: "terraform workspace select ${envName}",
        returnStatus: true
    )

    if (status !=0){
        echo "Workspace doesnot exist. Creating new workspace: ${envName}"
        sh "terraform workspace new ${envName}"
    }
    else{
        echo "Workspace ${envName} selected successfully"
    }
}