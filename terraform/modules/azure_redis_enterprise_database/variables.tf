variable "redis_enterprise_database_name" {
  type        = string
  description = "Redis Enterprise database name"
  validation {
    condition     = var.redis_enterprise_database_name == "default"
    error_message = "The only acceptable value for redis_enterprise_database_name is 'default'."
  }
}

# variable "rg_name" {
#   type        = string
#   description = "Resource group name"
# }

variable "cluster_id" {
  type        = string
  description = "ID of the Redis Enterprise cluster"
}

variable "client_protocol" {
  type        = string
  description = "Client protocol for the Redis Enterprise database"
  validation {
    condition     = contains(["Encrypted", "Plaintext"], var.client_protocol)
    error_message = "Client protocol must be either 'Encrypted' or 'Plaintext'."
  }
}

variable "clustering_policy" {
  type        = string
  description = "Clustering policy for the Redis Enterprise database"
  validation {
    condition     = contains(["EnterpriseCluster", "OSSCluster"], var.clustering_policy)
    error_message = "Clustering policy must be either 'EnterpriseCluster' or 'OSSCluster'."
  }
}

variable "eviction_policy" {
  type        = string
  description = "Redis eviction policy"
  validation {
    condition = contains(
      ["AllKeysLFU", "AllKeysLRU", "AllKeysRandom", "VolatileLRU", "VolatileLFU", "VolatileTTL", "VolatileRandom", "NoEviction"],
      var.eviction_policy
    )
    error_message = "Eviction policy must be one of 'AllKeysLFU', 'AllKeysLRU', 'AllKeysRandom', 'VolatileLRU', 'VolatileLFU', 'VolatileTTL', 'VolatileRandom', or 'NoEviction'."
  }
}

variable "module_db" {
  type = map(object({
    name = string
  }))
  description = "Module block for Redis Enterprise Database"
  validation {
    condition     = alltrue([for db in var.module_db : contains(["RedisBloom", "RedisTimeSeries", "RediSearch", "RedisJSON"], db.name)])
    error_message = "Module name must be one of 'RedisBloom', 'RedisTimeSeries', 'RediSearch', or 'RedisJSON'."
  }
}


variable "port" {
  type        = number
  description = "Port number for the Redis Enterprise database"
  validation {
    condition     = var.port >= 1000 && var.port <= 65535
    error_message = "Port must be between 1000 and 65535."
  }
}

variable "linked_database_id" {
  type        = list(string)
  description = "A list of database resources to link with this database with a maximum of 5."
  validation {
    condition     = length(var.linked_database_id) <= 5
    error_message = "You can link a maximum of 5 databases."
  }
}

variable "linked_database_group_nickname" {
  type        = string
  description = "Nickname of the group of linked databases"
}

