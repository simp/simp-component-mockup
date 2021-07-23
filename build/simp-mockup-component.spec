%global package_name main

%global main_version 1.0.10
%global sub_version 0.8.0

Summary: a main package
Name: main
Version: %{main_version}
Release: 1%{?dist}
Group: Applications/System
License: Apache-2.0
Source0: %{name}-%{main_version}-%{release}.tar.gz
BuildArch: noarch
Provides: mockup_component(%{package_name}) = %{main_version}

%description
main package

%package doc
Summary: Documentation for %{name}
Group: Documentation
BuildArch: noarch

%description doc
Documentation for %{name}

%package sub
Summary: A sub package
Version: %{sub_version}
Release: 1
License: GPL-2.0
BuildArch: noarch
Provides: mockup_component(%{package_name}-sub) = %{sub_version}

%description sub
sub is required for the proper functionality of main

%prep

%build

%install

%files

%files sub

%files doc

%changelog
* Thu Aug 31 2017 Jane Doe <jane.doe@simp.com> - 1.0.10
- Fix bug Z

* Mon Jun 12 2017 Jane Doe <jane.doe@simp.com> - 1.0.10
- Prompt user for new input

* Fri Jun 02 2017 John Q. Public <john.q.public@simp.com> - 1.0.10-1
- Expand X
- Fix Y
