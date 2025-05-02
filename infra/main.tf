provider "aws" {
  region = var.region
}

module "vpc" {
  source                 = "./modules/vpc"
  region                 = var.region
  project_name           = var.project_name
  vpc_cidr               = var.vpc_cidr
  public_subnet_az1_cidr = var.public_subnet_az1_cidr
  public_subnet_az2_cidr = var.public_subnet_az2_cidr
}

module "security_group" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source       = "./modules/iam"
  project_name = module.vpc.project_name
}

module "acm" {
  source           = "./modules/acm"
  domain_name      = var.domain_name
  alternative_name = var.alternative_name
}

module "alb" {
  source                = "./modules/alb"
  project_name          = module.vpc.project_name
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  vpc_id                = module.vpc.vpc_id
  certificate_arn       = module.acm.certificate_arn
}

module "ecr" {
  source = "./modules/ecr"
  project_name = module.vpc.project_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  project_name = module.vpc.project_name
  retention_in_days = var.retention_in_days
}

module "ecs" {
  source                       = "./modules/ecs"
  project_name                 = module.vpc.project_name
  ecs_tasks_execution_role_arn = module.iam.ecs_tasks_execution_role_arn
  repository_url               = module.ecr.repository_url
  public_subnet_az1_id         = module.vpc.public_subnet_az1_id
  public_subnet_az2_id         = module.vpc.public_subnet_az2_id
  alb_security_group_id        = module.security_group.alb_security_group_id
  alb_target_group_arn         = module.alb.alb_target_group_arn
  log_group_name               = module.cloudwatch.log_group_name 
  log_group_arn                = module.cloudwatch.log_group_arn
  region                       = module.vpc.region 
}