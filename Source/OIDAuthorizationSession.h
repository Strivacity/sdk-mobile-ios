//
//  OIDAuthorizationSession.h
//  Strivacity
//
//  Copyright (c) 2022 Strivacity <opensource@strivacity.com>
//

#ifndef OIDAuthorizationSession_h
#define OIDAuthorizationSession_h

#import <AppAuth/OIDExternalUserAgentSession.h>

/**
 * We need to have these objects declaration to be able to use hybrid flow.
 * Internal implementation of the AppAuth framework uses the ASWebAuthenticationSession object
 * which for hybrid flow request returns the URL which contains the '#' character instead of '?',
 * OIDURLComponents object which takes this URL can't be created with such URL
 * and because of this the hybrid flow fails with error. That's why we implemented the hybrid flow on owr own
 * and had to declare some objects that are not directly accessed in AppAuth framework.
 *
 * OIDAuthorizationSession object is taken part in hybrid flow, it assigned to currentAuthorizationFlow object in [AuthClient] on hybrid flow success.
 * OIDExternalUserAgentSession and OIDAuthorizationRequest declarations are necessary to be able to create OIDAuthorizationSession object.
 */

@protocol OIDExternalUserAgentSession;
@class OIDAuthorizationRequest;

@interface OIDAuthorizationSession: NSObject<OIDExternalUserAgentSession>
- (instancetype)initWithRequest:(OIDAuthorizationRequest *)request;
@end

#endif /* OIDAuthorizationSession_h */
