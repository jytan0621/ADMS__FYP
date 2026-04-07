/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.Utility;

import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailUtility {
    
    // 1. Setup your email credentials
    private static final String SENDER_EMAIL = "jytan0621@gmail.com"; // PUT YOUR GMAIL HERE
    private static final String APP_PASSWORD = "fxnd bvmo kfft ercq";  // PUT YOUR 16-DIGIT APP PASSWORD HERE

    public static void sendEmail(String recipientEmail, String subject, String messageContent) throws MessagingException {
        
        // 2. Setup Mail Server Properties
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");

        // 3. Create a Session with Authentication
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, APP_PASSWORD);
            }
        });

        // 4. Create the Email Message
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
        message.setSubject(subject);
        message.setText(messageContent);

        // 5. Send the Email
        Transport.send(message);
        System.out.println("Email sent successfully to " + recipientEmail);
    }
}