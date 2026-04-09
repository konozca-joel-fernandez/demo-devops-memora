/**
 * Created by mbujak003 on 20.04.2021.
 */

@RestResource(UrlMapping='/userinfo')
global with sharing class ONE_UserInfoWebservice {

    @HttpGet
    global static void getData() {
        Map<String, Object> userinf = new Map<String,Object> {
            'UserId' => UserInfo.getUserId(),
            'Name' => UserInfo.getUserName(),
            'ProfileId' => UserInfo.getProfileId(),
            'FirstName' => UserInfo.getFirstName(),
            'LastName' => UserInfo.getLastName(),
            'DefaultCurrency' => UserInfo.getDefaultCurrency(),
            'Language' => UserInfo.getLanguage(),
            'Locale' => UserInfo.getLocale(),
            'OrganizationId' => UserInfo.getOrganizationId(),
            'OrganizationName' => UserInfo.getOrganizationName(),
            'TimeZone' => String.valueOf(UserInfo.getTimeZone()),
            'UiTheme' => UserInfo.getUiTheme(),
            'UiThemeDisplayed' => UserInfo.getUiThemeDisplayed(),
            'UserEmail' => UserInfo.getUserEmail(),
            'UserRoleId' => UserInfo.getUserRoleId(),
            'UserType' => UserInfo.getUserType()
        };

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(userinf));
    }
}