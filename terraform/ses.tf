# Identidade de e-mail para o triaige-srv-notification enviar via SES.
#
# Recurso novo: ao aplicar, a AWS envia um e-mail de verificacao para
# var.ses_sender_email. A identidade so fica "verified" depois que alguem
# clicar no link recebido nessa caixa de entrada (modo sandbox do SES).
#
# A mesma identidade verificada e usada como remetente (SES_FROM_EMAIL) e
# como destinatario de teste pelo triaige-srv-notification.
resource "aws_ses_email_identity" "notification_sender" {
  email = var.ses_sender_email
}
