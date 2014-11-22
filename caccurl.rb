require 'formula'

class Caccurl < Formula
  homepage 'http://curl.haxx.se/'
  url 'http://curl.haxx.se/download/curl-7.39.0.tar.gz'
  mirror 'ftp://ftp.sunet.se/pub/www/utilities/curl/curl-7.39.0.tar.gz'
  sha256 'a3a7c2b9e7416c728469eb4cb5b61e9161335df4278329e1d9cc3c194e25d795'
  
  option 'with-ssh', 'Build with scp and sftp support'
  option 'with-ares', 'Build with C-Ares async DNS support'
  option 'with-gssapi', 'Build with GSSAPI/Kerberos authentication support.'

  # Don't depends_on 'openssl' because it doesn't use the system-wide openssl.cnf
  depends_on 'engine_pkcs11'
  depends_on 'cackey.rb'
  depends_on 'pkg-config' => :build
  depends_on 'libmetalink' => :optional
  depends_on 'libssh2' if build.with? 'ssh'
  depends_on 'c-ares' if build.with? 'ares'

  stable do
      patch :DATA
  end

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    # args << "--with-ssl=#{Formula.factory("openssl").opt_prefix}"

    args << "--with-libssh2" if build.with? 'ssh'
    args << "--with-libmetalink" if build.with? 'libmetalink'
    args << "--enable-ares=#{Formula.factory("c-ares").opt_prefix}" if build.with? 'ares'
    args << "--with-gssapi" if build.with? 'gssapi'
    args << "--with-ca-bundle=/System/Library/OpenSSL/certs/dod_ca_chain.pem"

    system "./configure", *args
    system "make install"
  end
end

__END__
diff --git a/lib/easy.c b/lib/easy.c
index 1dbdcb7..0fc4f7a 100644
--- a/lib/easy.c
+++ b/lib/easy.c
@@ -926,6 +926,19 @@ CURL *curl_easy_duphandle(CURL *incurl)
                              data->state.resolver) != CURLE_OK)
     goto fail;
 
+  /* If set, clone the handle to the engine being used. */
+#if defined(USE_SSLEAY) && defined(HAVE_OPENSSL_ENGINE_H)
+  if (data->state.engine) {
+      /* state.engine existing means curl_ossl_set_engine was
+       * previously successful.  Because curl_ossl_set_engine worked,
+       * we can query the already-set engine for that handle and use
+       * that to increment a reference:
+       */
+      Curl_ssl_set_engine(outcurl, ENGINE_get_id(data->state.engine));
+  }
+#endif /* USE_SSLEAY */
+
+
   Curl_convert_setup(outcurl);
 
   outcurl->magic = CURLEASY_MAGIC_NUMBER;
diff --git a/lib/vtls/openssl.c b/lib/vtls/openssl.c
index d0a83f7..67260e9 100644
--- a/lib/vtls/openssl.c
+++ b/lib/vtls/openssl.c
@@ -734,6 +734,11 @@ int Curl_ossl_init(void)
   /* Lets get nice error messages */
   SSL_load_error_strings();
 
+  /* Load config file */
+  OPENSSL_load_builtin_modules();
+  if (CONF_modules_load_file(getenv("OPENSSL_CONF"), NULL, 0) <= 0)
+      return 0;
+
   /* Init the global ciphers and digests */
   if(!SSLeay_add_ssl_algorithms())
     return 0;
