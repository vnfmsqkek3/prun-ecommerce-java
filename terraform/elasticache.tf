# =============================================================================
# elasticache.tf — ElastiCache Redis (Spring Session 저장소)
# replication group (cluster mode disabled): 1 primary + 1 replica, Multi-AZ 자동 failover.
# transit encryption 미사용 → backend 가 spring.data.redis host/port 로 평문 연결
# (private cache subnet 격리 전제). primary_endpoint_address 를 REDIS_HOST 로 주입.
# =============================================================================

resource "aws_elasticache_subnet_group" "session" {
  name       = "${local.name_prefix}-pri-redis-subnet-group"
  subnet_ids = [for s in aws_subnet.private_cache : s.id]
  tags       = merge(local.common_tags, { Name = "${local.name_prefix}-pri-redis-subnet-group" })
}

resource "aws_elasticache_replication_group" "session" {
  replication_group_id = "${local.name_prefix}-pri-redis"
  description          = "furn Spring Session store (Redis)"
  engine               = "redis"
  engine_version       = var.redis_engine_version
  node_type            = var.redis_node_type
  port                 = 6379
  parameter_group_name = var.redis_parameter_group_name

  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true

  subnet_group_name  = aws_elasticache_subnet_group.session.name
  security_group_ids = [aws_security_group.cache.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = false

  snapshot_retention_limit = 0 # 세션 캐시 — 백업 불필요

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-pri-redis" })
}
