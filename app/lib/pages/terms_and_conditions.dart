import 'package:app/components/header.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              maintColor.primary,
              maintColor.primaryDark,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: AppSizes.blockSizeVertical * 3),
            Header(profile: false, light: false),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: AppSizes.blockSizeVertical * 10),
                decoration: BoxDecoration(color: maintColor.primaryComplement),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.blockSizeHorizontal * 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms and Conditions',
                          style: TextStyle(
                            fontSize: AppSizes.blockSizeHorizontal * 7,
                            fontWeight: FontWeight.w800,
                            color: maintColor.primaryDark,
                          ),
                        ),
                        SizedBox(height: AppSizes.blockSizeVertical * 3),
                        
                        // Data Privacy Section
                        _buildSectionTitle('Confidentiality and Data Privacy', appSizes),
                        SizedBox(height: AppSizes.blockSizeVertical * 1),
                        _buildParagraph(
                          'In compliance with the Data Privacy Act of the Philippines (Republic Act No. 10173), '
                          'all responses in this evaluation are strictly confidential. Your personal information '
                          'will be collected, processed, and stored in accordance with the provisions of the Act.',
                          appSizes,
                        ),
                        SizedBox(height: AppSizes.blockSizeVertical * 2),
                        
                        // User Agreement Section
                        _buildSectionTitle('User Agreement', appSizes),
                        SizedBox(height: AppSizes.blockSizeVertical * 1),
                        _buildParagraph(
                          'By using MAINT-SMART, you agree to the following terms and conditions:',
                          appSizes,
                        ),
                        SizedBox(height: AppSizes.blockSizeVertical * 1.5),
                        
                        _buildBulletPoint(
                          '1. Account Responsibility',
                          'You are responsible for maintaining the confidentiality of your account credentials '
                          'and for all activities that occur under your account.',
                          appSizes,
                        ),
                        
                        _buildBulletPoint(
                          '2. Tool Borrowing and Return',
                          'You agree to borrow tools responsibly and return them in good condition within the '
                          'specified timeframe. Any damage or loss may result in penalties or replacement fees.',
                          appSizes,
                        ),
                        
                        _buildBulletPoint(
                          '3. Accurate Information',
                          'You agree to provide accurate and complete information during registration and to '
                          'update your information as necessary.',
                          appSizes,
                        ),
                        
                        _buildBulletPoint(
                          '4. Acceptable Use',
                          'You agree to use the application only for its intended purpose and not to engage in '
                          'any activities that may disrupt the service or violate any applicable laws.',
                          appSizes,
                        ),
                        
                        _buildBulletPoint(
                          '5. Data Collection and Use',
                          'We collect and process your personal information including name, email, ID number, '
                          'and academic information solely for the purpose of managing tool inventory and transactions. '
                          'Your data will not be shared with third parties without your consent.',
                          appSizes,
                        ),
                        
                        _buildBulletPoint(
                          '6. Service Availability',
                          'While we strive to maintain continuous service availability, we do not guarantee '
                          'uninterrupted access to the application and reserve the right to modify or discontinue '
                          'features with or without notice.',
                          appSizes,
                        ),
                        
                        _buildBulletPoint(
                          '7. Limitation of Liability',
                          'The application is provided "as is" without warranties of any kind. We shall not be '
                          'liable for any damages arising from the use or inability to use the application.',
                          appSizes,
                        ),
                        
                        SizedBox(height: AppSizes.blockSizeVertical * 2),
                        
                        _buildSectionTitle('Your Rights', appSizes),
                        SizedBox(height: AppSizes.blockSizeVertical * 1),
                        _buildParagraph(
                          'Under the Data Privacy Act, you have the right to:',
                          appSizes,
                        ),
                        SizedBox(height: AppSizes.blockSizeVertical * 1),
                        
                        _buildSimpleBullet('Access your personal data', appSizes),
                        _buildSimpleBullet('Correct inaccurate or incomplete data', appSizes),
                        _buildSimpleBullet('Request deletion of your data', appSizes),
                        _buildSimpleBullet('Object to processing of your data', appSizes),
                        _buildSimpleBullet('File a complaint with the National Privacy Commission', appSizes),
                        
                        SizedBox(height: AppSizes.blockSizeVertical * 3),
                        
                        _buildParagraph(
                          'By proceeding with registration, you acknowledge that you have read, understood, '
                          'and agree to these Terms and Conditions and our data privacy practices.',
                          appSizes,
                        ),
                        
                        SizedBox(height: AppSizes.blockSizeVertical * 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppSizes appSizes) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppSizes.blockSizeHorizontal * 5.5,
        fontWeight: FontWeight.w700,
        color: maintColor.primaryDark,
      ),
    );
  }

  Widget _buildParagraph(String text, AppSizes appSizes) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppSizes.blockSizeHorizontal * 4,
        fontWeight: FontWeight.w400,
        color: maintColor.blackText,
        height: 1.5,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildBulletPoint(String title, String description, AppSizes appSizes) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.blockSizeVertical * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.blockSizeHorizontal * 4.2,
              fontWeight: FontWeight.w600,
              color: maintColor.primaryDark,
            ),
          ),
          SizedBox(height: AppSizes.blockSizeVertical * 0.5),
          Text(
            description,
            style: TextStyle(
              fontSize: AppSizes.blockSizeHorizontal * 3.8,
              fontWeight: FontWeight.w400,
              color: maintColor.blackText,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBullet(String text, AppSizes appSizes) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSizes.blockSizeVertical * 0.5,
        left: AppSizes.blockSizeHorizontal * 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: AppSizes.blockSizeHorizontal * 4,
              color: maintColor.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppSizes.blockSizeHorizontal * 3.8,
                fontWeight: FontWeight.w400,
                color: maintColor.blackText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
