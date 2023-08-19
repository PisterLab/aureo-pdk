#! /usr/bin/env bash

source ./setup.sh

# Workaround for libssl for IC6.1.8 ISR20.
# See https://support.cadence.com/apex/ArticleAttachmentPortal?id=a1O0V000009Mo6IUAS&pageName=ArticleContent.export LD_PRELOAD=/usr/lib64/libssl.so.1.0.2k:/usr/lib64/libcrypto.so.1.0.2k
export LD_PRELOAD=/usr/lib64/libssl.so.1.1.1k:/usr/lib64/libcrypto.so.1.1.1k
# PATH setup.
export PATH=${CDS_HOME}/tools/plot/bin:${PATH}
export PATH=${CDS_HOME}/tools/dfII/bin:${PATH}
export PATH=${CDS_HOME}/tools/bin:${PATH}

# Virtuoso options.
export CDS_Netlisting_Mode=Analog
