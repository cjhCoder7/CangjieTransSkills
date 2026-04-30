package mail_importer.gmail

// === 测试用例 ===

@Test
class AuthorizerTest {

    @TestCase
    func testStaticOAuth2Provider(): Unit {
        let provider = StaticOAuth2Provider("test-token-123")
        @Expect(provider.getAccessToken(), "test-token-123")
    }

    @TestCase
    func testStaticOAuth2ProviderDifferentTokens(): Unit {
        let provider1 = StaticOAuth2Provider("token-aaa")
        let provider2 = StaticOAuth2Provider("token-bbb")
        @Expect(provider1.getAccessToken(), "token-aaa")
        @Expect(provider2.getAccessToken(), "token-bbb")
    }

    @TestCase
    func testAuthorizerWithToken(): Unit {
        let user = User("test@example.com")
        let authorizer = Authorizer(user)
        let provider = authorizer.authorizeWithToken("my-access-token")

        @Expect(provider.getAccessToken(), "my-access-token")
        @Expect(authorizer.getProvider().getAccessToken(), "my-access-token")
    }

    @TestCase
    func testAuthorizerNotAuthorizedThrows(): Unit {
        let user = User("test@example.com")
        let authorizer = Authorizer(user)

        @ExpectThrows[Exception]({
            authorizer.getProvider()
        })
    }

    @TestCase
    func testOAuth2TokenNotExpired(): Unit {
        let now = unsafe { time(CPointer<Int64>()) } * 1000
        let token = OAuth2Token("access", "refresh", 3600, now)
        @Expect(token.isExpired(), false)
    }

    @TestCase
    func testOAuth2TokenExpired(): Unit {
        let now = unsafe { time(CPointer<Int64>()) } * 1000
        // 设置为 2 小时前获取，有效期 1 小时
        let token = OAuth2Token("access", "refresh", 3600, now - 7200000)
        @Expect(token.isExpired(), true)
    }

    @TestCase
    func testTokenStoreRoundTrip(): Unit {
        let store = TokenStore("/tmp/test_mailimporter_tokens")
        let now = unsafe { time(CPointer<Int64>()) } * 1000
        let original = OAuth2Token("access123", "refresh456", 3600, now)

        store.saveToken("testuser@example.com", original)

        if (let Some(loaded) <- store.loadToken("testuser@example.com")) {
            @Expect(loaded.accessToken, "access123")
            @Expect(loaded.refreshToken, "refresh456")
            @Expect(loaded.expiresIn, 3600)
        } else {
            @Expect(true, false)
        }
    }
}
