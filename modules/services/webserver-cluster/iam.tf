### IAM users and policies
resource "aws_iam_user" "test" {
  name = each.value
  for_each = toset(var.user_names)
}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name = "cloudwatch_read_only"
  policy = data.aws_iam_policy_document.cloudwatch_read_only.json
}

resource "aws_iam_policy" "cloudwatch_full_access" {
  name = "cloudwatch_full_access"
  policy = data.aws_iam_policy_document.cloudwatch_full_access.json
}

data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:*"
    ]
    resources = ["*"]
  }
}