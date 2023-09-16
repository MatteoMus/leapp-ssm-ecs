import { Session } from "@noovolari/leapp-core/models/session";
import { AwsCredentialsPlugin } from "@noovolari/leapp-core/plugin-sdk/aws-credentials-plugin";
import { PluginLogLevel } from "@noovolari/leapp-core/plugin-sdk/plugin-log-level";

export class LeappSsmECSExec extends AwsCredentialsPlugin {
  get actionName(): string {
    return "Run ECS exec";
  }

  get actionIcon(): string {
    return "fas fa-th";
  }

  async applySessionAction(session: Session, credentials: any): Promise<void> {

    const env = {
      AWS_ACCESS_KEY_ID: credentials.sessionToken.aws_access_key_id,
      AWS_SECRET_ACCESS_KEY: credentials.sessionToken.aws_secret_access_key,
      AWS_SESSION_TOKEN: credentials.sessionToken.aws_session_token,
      AWS_REGION: session.region
    };

    this.pluginEnvironment.openTerminal("sh ~/.Leapp/plugins/leapp-ssm-ecs-exec/ecs.sh", env)
      .then(() => {
        this.pluginEnvironment.log("Terminal command successfully started", PluginLogLevel.info, true);
      })
      .catch((err) => {
        this.pluginEnvironment.log(`Error while executing the command: ${err.message}`, PluginLogLevel.error, true);
      });
  }
}
