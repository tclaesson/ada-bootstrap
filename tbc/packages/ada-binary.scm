(define-module (tbc packages ada-binary)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system copy)
  #:use-module (guix profiles)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu system)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (ice-9 match))

(define-public alire
  (package
    (name "alire")
    (version "1.2.2")
    (source (origin
	      (method url-fetch)
	      (uri "https://github.com/alire-project/alire/releases/download/v1.2.2/alr-1.2.2-bin-x86_64-linux.zip")
	      (sha256
	       (base32
		"1mn3jc8arp6l6na8z6ql24qxax1sxm9mg9wa8nfx70lcdgzyi3m7"))))
    (build-system copy-build-system)
    (arguments
     '(#:validate-runpath? #t
       #:strip-binaries? #f
       #:install-plan
       '(("alr" "bin/"))
       #:phases
       (modify-phases %standard-phases
	 (add-after 'install 'patch-binary
	   (lambda* (#:key inputs outputs #:allow-other-keys)
	     (invoke "patchelf"
		     "--set-interpreter"
		     (string-append (assoc-ref inputs "glibc")
				    "/lib/ld-linux-x86-64.so.2")
		     (string-append (assoc-ref outputs "out")
				    "/bin/alr"))
	     (invoke "patchelf"
		     "--set-rpath"
		     (string-append (assoc-ref inputs "glibc")
				    "/lib")
		     (string-append (assoc-ref outputs "out")
				    "/bin/alr")))))))
    (native-inputs (list unzip patchelf))
    (inputs (list glibc))
    (synopsis "alr")
    (description "alr")
    (home-page "hepp")
    (license license:gpl3+)))

(define-public ada-language-server
  (package
    (name "ada-language-server")
    (version "23.0.13")
    (source (origin
	      (method url-fetch)
	      (uri "https://github.com/AdaCore/ada_language_server/releases/download/23.0.13/als-23.0.13-Linux_amd64.zip")
	      (sha256
	       (base32 "102z4lqznzk1z8378chy7pn8am6yy7kpvdarkgqwxjr37g6dv3p7"))))
    (build-system copy-build-system)
    (arguments
     '(#:validate-runpath? #t
       #:strip-binaries? #f
       #:install-plan
       '(("ada_language_server" "bin/"))
       #:phases (modify-phases %standard-phases
		  (add-after 'install 'patch-binary
		    (lambda* (#:key inputs outputs #:allow-other-keys)
		      (invoke "patchelf"
			      "--set-interpreter"
			      (string-append (assoc-ref inputs "glibc")
					     "/lib/ld-linux-x86-64.so.2")
			      (string-append (assoc-ref outputs "out")
					     "/bin/ada_language_server"))
		      (invoke "patchelf"
			      "--set-rpath"
			      (string-append
			       (assoc-ref inputs "glibc") "/lib:"
			       (assoc-ref inputs "gmp")   "/lib")
			      (string-append (assoc-ref outputs "out") "/bin/ada_language_server")))))))
    (native-inputs (list unzip patchelf))
    (inputs (list glibc gmp))
    (synopsis "ada-language-server")
    (description "als")
    (home-page "hepp")
    (license license:gpl3+)))

(define-public gnat-bootstrap
  (package
    (name "gnat-bootstrap")
    (version "12.2.0-1")
    (supported-systems (list "x86_64-linux"))
    (source (origin
	      (method url-fetch)
	      (uri (string-append "https://github.com/alire-project/GNAT-FSF-builds/releases/download/gnat-"
				  version
				  "/gnat-x86_64-linux-"
				  version
				  ".tar.gz"))
	      (sha256
	       (base32
		"16gy4w6frykpq009vk8nw3z6950bivkfjdl29a9d8ywnwh8viwqi"))
	      (modules '((guix build utils)))
	      (snippet '(delete-file-recursively "bin/gdb")))) ;; gdb want ncurses-5

    (build-system copy-build-system)
    (arguments
     '(#:validate-runpath? #t
       #:strip-binaries? #f
       #:install-plan (map (lambda (path)
			     (list (string-append path
						  "/")
				   path))
			   (list "bin"
				 "etc"
				 "include"
				 "lib"
				 "lib64"
				 "libexec"
				 "share"
				 "x86_64-pc-linux-gnu"))
       #:phases (modify-phases %standard-phases
		  (add-after 'install 'patchelf-set-interpreter
		    (lambda* (#:key inputs outputs #:allow-other-keys)
		      (for-each (lambda (binary)
				  (invoke "patchelf"
					  "--set-interpreter"
					  (string-append (assoc-ref inputs "glibc")
							 "/lib/ld-linux-x86-64.so.2")
					  (string-append (assoc-ref outputs "out")
							 "/"
							 binary)))
				(list "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/cc1"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/cc1plus"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/collect2"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/g++-mapper-server"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/gnat1"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/lto-wrapper"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/lto1"
				      "bin/as"
				      "bin/c++"
				      "bin/cpp"
				      "bin/g++"
				      "bin/gcc"
				      "bin/gcov"
				      "bin/gcov-dump"
				      "bin/gcov-tool"
				      "bin/gnat"
				      "bin/gnatbind"
				      "bin/gnatchop"
				      "bin/gnatclean"
				      "bin/gnatkr"
				      "bin/gnatlink"
				      "bin/gnatls"
				      "bin/gnatmake"
				      "bin/gnatname"
				      "bin/gnatprep"
				      "bin/gp-archive"
				      "bin/gp-collect-app"
				      "bin/gp-display-src"
				      "bin/gp-display-text"
				      "bin/gprofng"
				      "bin/lto-dump"
				      "bin/x86_64-pc-linux-gnu-c++"
				      "bin/x86_64-pc-linux-gnu-g++"
				      "bin/x86_64-pc-linux-gnu-gcc"
				      "x86_64-pc-linux-gnu/bin/as"
				      "bin/x86_64-pc-linux-gnu-gcc-12.2.0"))))
		  (add-after 'patchelf-set-interpreter 'patchelf-set-rpath
		    (lambda* (#:key inputs outputs #:allow-other-keys)
		      (for-each (lambda (binary)
				  (invoke "patchelf"
					  "--set-rpath"
					  (string-append
					   (assoc-ref inputs "gcc:lib") "/lib:"
					   (assoc-ref inputs "glibc") "/lib:"
					   (assoc-ref inputs "expat") "/lib:"
					   (assoc-ref inputs "xz") "/lib")
					  (string-append
					   (assoc-ref outputs "out")
					   "/"
					   binary))
				  (invoke "patchelf"
					  "--shrink-rpath"
					  (string-append
					   (assoc-ref outputs "out")
					   "/"
					   binary)))
				(list "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/cc1"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/cc1plus"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/collect2"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/g++-mapper-server"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/gnat1"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/lto-wrapper"
				      "libexec/gcc/x86_64-pc-linux-gnu/12.2.0/lto1"
				      "bin/as"
				      "bin/c++"
				      "bin/cpp"
				      "bin/g++"
				      "bin/gcc"
				      "bin/gcov"
				      "bin/gcov-dump"
				      "bin/gcov-tool"
				      "bin/gnat"
				      "bin/gnatbind"
				      "bin/gnatchop"
				      "bin/gnatclean"
				      "bin/gnatkr"
				      "bin/gnatlink"
				      "bin/gnatls"
				      "bin/gnatmake"
				      "bin/gnatname"
				      "bin/gnatprep"
				      "bin/gp-archive"
				      "bin/gp-collect-app"
				      "bin/gp-display-src"
				      "bin/gp-display-text"
				      "bin/gprofng"
				      "bin/lto-dump"
				      "bin/x86_64-pc-linux-gnu-c++"
				      "bin/x86_64-pc-linux-gnu-g++"
				      "bin/x86_64-pc-linux-gnu-gcc"
				      "x86_64-pc-linux-gnu/bin/as"
				      "bin/x86_64-pc-linux-gnu-gcc-12.2.0"
				      "lib/gcc/x86_64-pc-linux-gnu/12.2.0/adalib/libgnarl-12.so"
				      "lib/gcc/x86_64-pc-linux-gnu/12.2.0/plugin/libcp1plugin.so"
				      "lib/gcc/x86_64-pc-linux-gnu/12.2.0/plugin/libcc1plugin.so"
				      "lib64/libasan.so"
				      "lib64/libcc1.so"
				      "lib64/libtsan.so"
				      "lib64/libubsan.so"
				      "lib64/liblsan.so"
				      "lib64/libstdc++.so"
				      "lib/gcc/x86_64-pc-linux-gnu/12.2.0/adalib/libgnat-12.so" )))))))
    (inputs
     `(("gcc:lib" ,gcc-12 "lib")
       ("gcc-toolchain" ,gcc-toolchain)
       ("glibc" ,glibc)
       ("expat" ,expat)
       ("xz" ,xz)))
    (native-inputs (list patchelf))
    
    (synopsis "Builds of the GNAT Ada compiler from FSF GCC releases")
    (description "XXX Do not install this package, install gnat instead. This is for bootstrapping compilation of GNAT")
    (home-page "https://github.com/alire-project/GNAT-FSF-builds")
    (license license:gpl3+)))
