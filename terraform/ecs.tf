module "ecs_cluster" {   
    source         = "./modules/ecs/cluster"
    project_name = "devops-interview"
}
module "ecs_cluster_service" {   
    source         = "./modules/ecs/service"
    subnet_ids_priv = module.networking.private_subnet_ids
    app_name = "api"
    service_name = "devops-interview-api"
    project_name = "devops-interview"
    container_name = "api-webhook"
    env = "dev"
    cluster_arn = module.ecs_cluster.cluster_arn
    listener = module.alb.listener_http_arn
    container_definitions_path = "task_definitions.json"
    container_port = "5000"
    vpc_id = module.networking.vpc_id
    log_group_path = "/ecs/task-api"
    alb_sg_id = module.alb.alb_sg_id
    target_group_arn = module.alb.target_group_arn
}
