resource "aws_codepipeline" "infra_pipeline" {
  name     = "infra-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      configuration = {
        Owner  = "seu-github"
        Repo   = "infra-serverless-aws"
        Branch = "main"
      }
    }
  }
}