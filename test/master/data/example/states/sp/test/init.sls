sp-test-file:
  file.managed:
    - name: /root/test/file.txt
    - mode: 0644
    - makedirs: True
    - contents: 'Salt Master test'

sp-test-secret:
  file.managed:
    - name: /root/test/secret.txt
    - mode: 0644
    - makedirs: True
    - contents_pillar: 'sp:test:secret'
