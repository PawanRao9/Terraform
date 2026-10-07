# Terraform Learning Workspace

This repository is a collection of small Terraform and AWS learning exercises. Each folder is an independent Terraform root module. Run Terraform commands from the folder you want to study or deploy; do not run them from the repository root unless you add root-module files there.

## What Is Here

| Folder               | Main topic            | What it demonstrates                                                                      |
| -------------------- | --------------------- | ----------------------------------------------------------------------------------------- |
| `aws-ec2`            | EC2 basics            | AWS provider, variables, an EC2 resource, and a public-IP output                          |
| `aws-s3`             | S3 object upload      | AWS and Random providers, generated bucket naming, and uploading `data.txt`               |
| `aws-vpc`            | VPC fundamentals      | VPC, public/private subnets, internet gateway, route table, and subnet association        |
| `project-2`          | VPC + EC2 + NGINX     | A larger networked EC2 example with HTTP security-group access and URL outputs            |
| `project_static_web` | S3 static website     | Bucket, website configuration, public access settings, bucket policy, and HTML/CSS upload |
| `tf_backend`         | Remote state          | An S3 backend configuration alongside an EC2 example                                      |
| `tf_variables`       | Variables and locals  | Typed variables, validation, object input, maps, `merge`, and root volume settings        |
| `tf-data-source`     | Data sources          | Looking up AMIs, security groups, caller identity, and region information                 |
| `tf-DS-ec2`          | EC2 from data sources | Looking up an existing VPC, subnet, security group, and AMI before creating an instance   |
| `tf-ops&exps`        | HCL expressions       | Lists, maps, objects, locals, arithmetic, conditionals, and `for` expressions             |

The repository also contains `.gitignore`, VS Code spelling settings, `push_log.txt`, and the existing `project-2/README.md`.

## Prerequisites

- Terraform CLI installed and available as `terraform -version`.
- An AWS account and credentials configured through the AWS CLI profile, environment variables, or another supported credential method.
- An AWS region that exists and an AMI ID valid in that region.
- Permission to create and destroy the resources used by the selected exercise.
- Cost awareness: EC2 instances, public IPv4 addresses, S3 storage, and related resources can incur charges.

Never commit credentials, `.tfstate` files, `.tfvars` files containing secrets, or `.terraform` directories. The repository `.gitignore` already excludes these common Terraform artifacts.

## Standard Workflow

From one exercise directory:

```powershell
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

Use `terraform plan -out=tfplan` when you need to review and apply one exact plan. Use `terraform show` to inspect a saved plan or state. `terraform console` is useful for experimenting with expressions and variables.

`terraform init` downloads providers and configures a backend. `validate` checks configuration structure and types but does not prove that an AMI exists or that AWS permissions are sufficient. `plan` evaluates data sources and contacts AWS, so it is the first meaningful cloud-side check.

## Folder Guide

### `aws-ec2`

Creates one `aws_instance.my_server` using the AWS provider. The region comes from `variables.tf`, and `output.tf` exposes `public_ip` as `server`.

Interview concepts: provider configuration, input variables, resource arguments, implicit outputs, and the difference between a Terraform resource address and an AWS resource ID.

Before applying, replace the placeholder AMI and use a valid EC2 type such as `t3.micro`; `t3_micro` is not the normal AWS instance-type spelling. The instance may also need a key pair, subnet, and security group for useful access.

### `aws-s3`

Uses `random_id.id` to make an almost-unique bucket name, creates `aws_s3_bucket.demo_bucket`, and uploads local `data.txt` with `aws_s3_object`. The `random` output exposes a URL-safe random value.

Interview concepts: provider version constraints, resource dependency through references, local file upload, and why globally unique S3 bucket names are useful. The bucket currently has no versioning, encryption, lifecycle rule, or public-access policy.

### `aws-vpc`

Creates a `10.0.0.0/16` VPC, two `/24` subnets, an internet gateway, a default route to the gateway, and an association between that route table and the public subnet. `ec2.tf` attempts to place an EC2 instance in the private subnet.

A subnet is only conventionally “public” when its route table has a path to an internet gateway and the instance has a public address. A private subnet normally needs a NAT gateway for outbound internet access, and a real production network should add explicit route tables, availability zones, network ACL decisions, and security groups.

### `project-2`

This is the intended end-to-end web-server exercise. It defines a VPC with public/private subnets, attaches an internet gateway to a public route table, creates an HTTP security group, launches an EC2 instance in the public subnet, installs NGINX with `user_data`, and outputs the instance IP and URL.

Interview concepts: dependency graph references, bootstrapping with user data, security-group ingress/egress, public IPs, and outputs. The existing `project-2/README.md` describes this goal.

The current files need correction before they can work: the AMI is empty, `t3_micro` should be a valid instance type, `vpc_security_group_ids` needs a list of IDs, the shell shebang is missing `#`, and several tag values are unquoted. A public HTTP rule is intentionally broad for a demo but should be restricted where possible.

### `project_static_web`

Intends to create a uniquely named S3 bucket, upload `index.html` and `styles.css`, enable website hosting, allow public reads, and output the website endpoint. The website assets are a simple animated HTML/CSS landing page.

Interview concepts: S3 website hosting versus CloudFront, object `content_type`, bucket policy, public-access blocks, and the security implications of anonymous reads.

This configuration is currently a draft and requires fixes: the bucket policy uses `jsondecode` on an object instead of encoding a policy document, the policy version is mistyped, the website configuration references nonexistent `aws_s3_bucket.example.id.id`, and the public-access settings intentionally disable protections. Prefer CloudFront plus private S3 access for a production website.

### `tf_backend`

Shows an S3 backend declaration with a bucket, key, and region, plus a small EC2 resource. The backend bucket must already exist before `terraform init` can configure it. In a team setup, add state locking using the mechanism supported by the Terraform/AWS versions in use, restrict bucket access, enable encryption and versioning, and avoid hard-coding backend settings when a partial configuration is more appropriate.

The EC2 values are placeholders and must be replaced before deployment. Backend configuration is initialized before normal resource planning, so backend failures happen early.

### `tf_variables`

Demonstrates:

- `aws_instance_type` as a required string with validation.
- `ec2_config` as a typed object.
- `additional_tags` as a `map(string)`.
- `locals` and `merge` for consistent tags.
- `root_block_device` customization.
- `.tfvars` files for environment-specific values.

The example currently has mismatches: the validation repeats `t2.micro` and does not allow the advertised `t3.micro`, the AMI is empty, the provider region `india` is not an AWS region code, and the defaults for `v_type`/`v_size` are reversed and have incompatible intent. `prod.auto.tfvars` also supplies numeric `v_size` while the object type says string. `terraform.tfvars` uses `t3.small`, which the current validation rejects.

### `tf-data-source`

Intends to find the latest Amazon AMI, an existing security group by tag, caller identity, and current region, then create a VPC and EC2 instance. Data sources read existing information; they do not manage the lifecycle of the object they find.

The file needs correction before validation: the VPC has no `cidr_block`, `aws_availability_zone` is declared as a resource rather than a data source, output `AZ` references undefined `ava`, duplicate `output "output"` names are present in `tf-ops&exps` rather than here, and multiple tag values are unquoted. The AMI data source also needs useful filters such as architecture, virtualization type, and root-device type for predictable results.

### `tf-DS-ec2`

Looks up the default/available VPC, a subnet tagged `my_private_subnet`, the latest Amazon AMI, and a security group, then creates an EC2 instance in that subnet.

Interview concepts: data source filters, selecting existing infrastructure, and the distinction between `security_groups` (legacy/default-VPC style name input) and `vpc_security_group_ids` (VPC security-group ID input).

The example is incomplete: the security-group lookup has no filters, the AMI needs stronger filters, the instance type spelling should be corrected, and the unquoted `MY_SERVER` tag value is treated as a reference rather than a string.

### `tf-ops&exps`

A local-only HCL exercise with no cloud provider. It declares a number list, a list of person objects, and a number map. Locals calculate multiplication, addition, inequality, doubled numbers, odd numbers, and first names using `for` expressions.

The intended study examples are:

```hcl
[for number in var.num_list : number * 2]
[for number in var.num_list : number if number % 2 != 0]
[for person in var.person_list : person.fname]
```

The current file incorrectly uses `var.var.num_list` and `var.var.person_list`, and it declares two outputs with the same name. The local values should be referenced as `var.num_list` and the outputs should have unique names.

## Terraform Interview Preparation

### Core answers to know

- **What is Terraform?** An infrastructure-as-code tool that describes desired infrastructure declaratively and reconciles real infrastructure with configuration.
- **What is a provider?** A plugin that translates Terraform resources and data sources into API operations for AWS or another platform.
- **Resource versus data source?** A resource is managed by Terraform; a data source reads information about something managed elsewhere or discovered at plan time.
- **What is state?** Terraform's record of managed objects and their attributes. It lets Terraform map configuration addresses to real infrastructure and calculate changes.
- **Why use remote state?** Shared storage, centralized access control, backups/versioning, and collaboration. Protect it because state can contain sensitive values.
- **What is a plan?** A proposed change set calculated from configuration, state, and provider APIs. `apply` executes an approved plan.
- **How does Terraform know order?** References such as `aws_vpc.my_vpc.id` create implicit dependencies. `depends_on` is for dependencies Terraform cannot infer.
- **What are variables, locals, and outputs?** Variables are caller-provided inputs, locals are reusable internal expressions, and outputs expose selected values to users or other modules.
- **What is idempotency?** Reapplying unchanged configuration should produce no changes, except for external drift or resources with intentionally changing values.
- **How should secrets be handled?** Use a secret manager or protected variables, mark sensitive outputs, secure state, and never commit secrets to Git.

### AWS networking vocabulary

- A VPC is an isolated regional network with a CIDR range.
- Subnets are inside one availability zone and divide the VPC CIDR.
- An internet gateway enables internet routing for resources with a public route and public addressing.
- A route table decides where packet destinations go; association attaches it to a subnet.
- A security group is a stateful virtual firewall attached to an ENI/instance. Ingress is inbound; egress is outbound.
- A public subnet is not automatically enough for internet access: route, public IP, security group, and application listener must all align.

### 50 Interview Questions and Answers

#### Terraform fundamentals

1. **What problem does Terraform solve?** Terraform lets teams define infrastructure in code, review proposed changes, and create or update resources consistently through provider APIs.
2. **What does declarative mean in Terraform?** You describe the desired end state rather than writing every API call or procedural step needed to reach it.
3. **What is HCL?** HCL, or HashiCorp Configuration Language, is the configuration language used by Terraform for blocks, arguments, expressions, and types.
4. **What is a Terraform configuration?** It is the collection of `.tf` files in one directory that Terraform loads as a single root module.
5. **Why can a directory contain several `.tf` files?** Terraform combines all files in the same directory, so the files can separate providers, variables, resources, and outputs for readability.
6. **What is a provider?** A provider is a plugin that implements resources and data sources for a platform such as AWS.
7. **What is the `terraform` block used for?** It declares Terraform settings such as required providers, required Terraform versions, and backend configuration.
8. **What is a provider version constraint?** It limits which provider releases Terraform may select, helping avoid unexpected provider behavior changes.
9. **What does `terraform init` do?** It initializes the working directory, downloads providers and modules, configures the backend, and creates dependency metadata.
10. **What does `terraform validate` check?** It checks configuration syntax, references, and types after initialization; it does not confirm that AWS credentials, permissions, or an AMI are usable.
11. **What does `terraform plan` do?** It compares configuration with state and the provider's current observations, then displays the proposed create, update, and destroy actions.
12. **What does `terraform apply` do?** It executes a plan after approval, or executes a previously saved plan when one is supplied.
13. **What does `terraform destroy` do?** It plans and removes resources managed by the current state and configuration.
14. **What is a resource address?** It is Terraform's logical path, such as `aws_instance.my_server`, used to identify an object in configuration and state.
15. **What is an implicit dependency?** A reference such as `aws_vpc.my_vpc.id` tells Terraform that the referenced resource must be available first.
16. **When should `depends_on` be used?** Use it only for dependencies Terraform cannot infer from an expression, such as an operational dependency hidden behind an external system.
17. **What is drift?** Drift is a difference between the real infrastructure and the attributes recorded in Terraform state or described by configuration.
18. **How can drift be detected?** Run `terraform plan` or `terraform refresh-only`; Terraform compares the provider's current values with its state.
19. **What is idempotency?** Running the same configuration repeatedly should converge on the same infrastructure and produce no changes when nothing has changed.
20. **What is the difference between Terraform and a script?** Terraform maintains a dependency graph and state to calculate changes, while a script usually executes steps without that built-in lifecycle model.

#### State, variables, and reusable design

21. **What is Terraform state?** State maps Terraform resource addresses to real infrastructure and stores attributes needed to calculate future changes.
22. **Why is state important?** Without state, Terraform cannot reliably know which remote object belongs to each resource address or what it managed previously.
23. **Why use a remote S3 backend?** It gives a team shared state storage, centralized access control, durability, and a place to coordinate infrastructure changes.
24. **What must exist before initializing the S3 backend in `tf_backend`?** The backend bucket and the credentials needed to access it must already be available; Terraform cannot use the backend to create itself.
25. **How should remote state be protected?** Restrict IAM access, enable encryption and versioning, use locking where supported, audit access, and treat state as sensitive.
26. **Can a backend use variables?** Backend configuration is initialized before normal variables are evaluated, so use a partial backend configuration or `-backend-config` values instead of ordinary input variables.
27. **What is a variable?** A variable is an input contract that lets callers provide values without changing the module's implementation.
28. **What is a local value?** A local value names a reusable expression inside a module; it is not a caller input and is not normally shown as an output.
29. **What is an output?** An output publishes a value from a module, such as an EC2 public IP or S3 website endpoint.
30. **Why specify variable types?** Types catch incorrect input early and document whether a value is a string, number, list, map, object, or another shape.
31. **What is variable validation?** A validation block rejects invalid input during planning with a custom error message.
32. **What is wrong with the current `tf_variables` validation?** It checks `t2.micro` twice, so it does not implement the stated t2/t3 intent and rejects the configured `t3.small` value.
33. **How are variable values supplied?** They can come from defaults, `.tfvars` files, `*.auto.tfvars`, `-var`, `-var-file`, or environment variables such as `TF_VAR_region`.
34. **Which variable value wins when several sources provide it?** Terraform applies a defined precedence order; explicit command-line values have higher precedence than automatically loaded variable files and defaults.
35. **What is a sensitive variable or output?** Marking it `sensitive = true` hides it from normal CLI display, but it may still be stored in state and must still be protected.
36. **What is a module?** A module is a reusable collection of Terraform configuration; every working directory is a root module and can call child modules.
37. **Why use modules?** Modules standardize repeated infrastructure, expose a smaller input/output interface, and reduce copy-and-paste configuration.
38. **What makes a good module interface?** Use clear typed variables, useful descriptions, sensible defaults, validation, minimal outputs, and predictable naming and tagging.
39. **What is `terraform import` for?** It associates an existing remote object with a Terraform resource address so that Terraform can manage it after the configuration is written.
40. **What is `terraform state mv` for?** It changes a resource address in state without destroying the remote object, which is useful during refactoring.

#### HCL expressions and data sources

41. **What is a data source?** A data source reads existing or discovered information, such as an AMI or VPC, without creating or managing that object.
42. **What is the difference between a resource and a data source in this workspace?** `aws_instance` creates an EC2 instance, while `data "aws_ami"` looks up an AMI that an instance can use.
43. **Why should an AMI data source have filters?** `most_recent = true` alone can select an unexpected image; filters for owner, architecture, virtualization, name, and root device make selection predictable.
44. **What is a `for` expression?** It transforms or filters a collection, such as doubling numbers or extracting `fname` from each person object in `tf-ops&exps`.
45. **What is the difference between a list and a map?** A list is ordered and indexed, while a map contains key-value pairs accessed by key.
46. **What is an object type?** An object is a structured value with named attributes and declared attribute types, like the `ec2_config` input.
47. **What does `merge` do?** It combines maps; later maps override earlier values when keys overlap.
48. **Why are duplicate output names invalid?** Output names must be unique within a module because Terraform uses them as addresses; the two `output "output"` blocks need different names.
49. **What does `var.var.num_list` mean in the expressions example?** It incorrectly asks for a variable named `var` with an attribute named `num_list`; the correct reference is `var.num_list`.
50. **Why are unquoted tag values a problem?** A value such as `My_VPC` is interpreted as a reference or expression, not literal text; tag strings should be quoted, for example `name = "My_VPC"`.

#### AWS and deployment design

51. **What is a VPC?** A VPC is a logically isolated AWS network with a CIDR range, subnets, routes, and network controls.
52. **What is a subnet?** A subnet is a range of IP addresses inside a VPC and belongs to one availability zone.
53. **What makes a subnet public?** It has a route to an internet gateway, and a resource in it also needs appropriate public addressing and security rules to be reachable.
54. **What does an internet gateway do?** It provides the VPC edge path for internet communication when route tables and resource addressing allow it.
55. **What does a route table do?** It maps destination CIDR blocks to targets such as an internet gateway, NAT gateway, or local VPC route.
56. **What is a NAT gateway used for?** It lets private-subnet resources initiate outbound internet connections without accepting unsolicited inbound internet connections.
57. **What is a security group?** It is a stateful virtual firewall associated with an EC2 network interface; rules control allowed inbound and outbound traffic.
58. **What is the difference between ingress and egress?** Ingress is incoming traffic to a resource; egress is outgoing traffic from it.
59. **Why is `0.0.0.0/0` on port 80 risky?** It allows HTTP connections from anywhere. It may be acceptable for a public demo, but narrower sources or a load balancer should be used where possible.
60. **What does EC2 `user_data` do?** It supplies startup instructions that can install packages and configure an instance when it boots.
61. **What is wrong with the NGINX user data in `project-2`?** The shebang is written as `!/bin/bash` instead of `#!/bin/bash`, so the script should be corrected before relying on it.
62. **Why is `vpc_security_group_ids` usually preferred in a VPC?** It accepts security-group IDs and works clearly with non-default VPCs; the older `security_groups` argument is name-based and has limitations.
63. **Why does an EC2 instance need a valid AMI?** The AMI supplies the operating system and boot configuration; an empty or fake AMI ID cannot launch an instance.
64. **Why is `t3_micro` invalid?** AWS instance types use a dot, such as `t3.micro`; Terraform passes the exact string to AWS.
65. **Why must an S3 bucket name be unique?** S3 bucket names share a global namespace, so a name that exists anywhere can conflict; the random suffix helps avoid collisions.
66. **What does `aws_s3_object` do?** It uploads or manages an object at a bucket and key, using a local source file such as `data.txt`.
67. **What is S3 versioning?** It preserves multiple versions of an object, helping recover from accidental overwrite or deletion.
68. **What is the difference between S3 website hosting and CloudFront?** S3 website hosting serves a simple public endpoint; CloudFront adds caching, TLS, edge delivery, and can keep the bucket private with origin access controls.
69. **Why should a production website avoid a public S3 bucket?** Anonymous bucket access increases exposure; CloudFront with private bucket access and least-privilege policies is safer.
70. **What should be reviewed before applying these examples?** Check provider versions, region, AMI, credentials, types, references, route and security rules, S3 access policies, estimated cost, and the complete `terraform plan`.

### Stronger production practices

Use valid region and AMI inputs, pin provider versions deliberately, add required variables and descriptions, use modules for repeated infrastructure, add validation and preconditions, format and validate in CI, review plans, tag resources consistently, enable S3 encryption/versioning, restrict network access, and add tests or policy checks. Keep each independent exercise in its own state unless intentionally composing modules.

## Recommended Study Order

1. Start with `tf-ops&exps` to learn HCL types and expressions.
2. Read `aws-ec2` for the smallest AWS resource example.
3. Study `aws-s3` for multiple providers and resource references.
4. Build the network model in `aws-vpc`.
5. Read `project-2` as the combined EC2 web-server design.
6. Compare `tf-data-source` and `tf-DS-ec2` with resources created by Terraform.
7. Study `tf_variables` for reusable input design.
8. Finish with `tf_backend` and state-management interview questions.
9. Treat `project_static_web` as a design review exercise: identify and repair its policy and website configuration before deploying.

## Important Cleanup Before Deployment

Do not run `apply` on the examples unchanged. First replace placeholder AMIs, correct instance types and regions, quote literal tag values, fix invalid references and types, add security groups where needed, and run `terraform fmt`, `terraform validate`, and `terraform plan` inside the selected folder. Review all public S3 and HTTP access rules carefully, then destroy temporary resources when the exercise is complete.
