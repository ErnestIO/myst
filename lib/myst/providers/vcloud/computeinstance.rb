# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module Myst
  module Providers
    module VCloud
      class ComputeInstance
        attr_reader :ref, :vapp, :vm, :client

        def initialize(args)
          # Ref is for VApp.
          # It will grab the first vm inside of the vapp,
          # So dont expect it to work when using more than one vm per vapp! :)
          @ref = args[:ref]
          @client = args[:client]
          load if ref
        end

        def load
          @vapp = Vapp.getVappByReference(client, ref)
          @vm = vapp.childrenVms.first
        end

        attr_writer :ref

        def instantiate(name, network, image)
          configure_networking(network)
          instantiate_vapp_template_params
          instantiate_vapp_template_params.setName(name)
          instantiate_vapp_template_params.setSource(image.ref)
          instantiate_vapp_template_params.setInstantiationParams(instantiation_params)
          instantiate_vapp_template_params
        end

        def tasks
          tasks = []
          vapp_tasks = vapp ? vapp.getTasks : []
          vm_tasks = vm ? vm.getTasks : []
          vm_tasks.each { |t| tasks << t }
          vapp_tasks.each { |t| tasks << t }
          tasks
        end

        def name
          vapp.getResource.getName
        end

        def name=(name)
          # Set VApp Name
          vapp.getResource.setName(name)
          vapp.updateVapp(vapp.getResource).waitForTask(0, 1000)
          # Set VM Name
          vm.getResource.setName(name)
          vm.updateVM(vm.getResource).waitForTask(0, 1000)
        end

        def hostname
          customSection = vm.getGuestCustomizationSection
          customSection.getComputerName
        end

        def hostname=(hostname)
          customSection = vm.getGuestCustomizationSection
          customSection.setEnabled(true)
          customSection.setComputerName(hostname)
          vm.updateSection(customSection).waitForTask(0, 1000)
        end

        def power_on
          vapp.powerOn.waitForTask(0)
        end

        def power_off
          vapp.powerOff.waitForTask(0)
        end

        def undeploy
          vapp.undeploy(UndeployPowerActionType.const_get('DEFAULT')).waitForTask(0) if vapp.isDeployed
        end

        def delete
          undeploy
          vapp.delete.waitForTask(0)
        end

        def cpus
          vm.getCpu.noOfCpus
        end

        def cpus=(cpu_size)
          cpuResource = vm.getCpu
          cpuResource.setNoOfCpus(cpu_size)
          vm.updateCpu(cpuResource).waitForTask(0, 1000)
        end

        def memory
          vm.getMemory.memorySize
        end

        def memory=(memory_size)
          memoryResource = vm.getMemory
          memoryResource.setMemorySize(memory_size)
          vm.updateMemory(memoryResource).waitForTask(0, 1000)
        end

        def disks
          vm.getDisks
        end

        # Expects AttachedStorage
        def add_disk(disk)
          disks.add(disk.disk)
          vm.updateDisks(vm.getDisks).waitForTask(0, 1000)
        end

        def nics
          vm.getNetworkCards
        end

        # Expects NetworkInterface
        def add_nic(nic)
          nics.add(nic.interface)
          vm.updateNetworkCards(nics).waitForTask(0, 1000)
        end

        private

        def network_configuration
          @network_configuration ||= NetworkConfigurationType.new
        end

        def vapp_network_configuration
          @vapp_network_configuration ||= VAppNetworkConfigurationType.new
        end

        def network_config_section
          @network_config_section ||= NetworkConfigSectionType.new
        end

        def network_info
          @network_info ||= MsgType.new
        end

        def instantiation_params
          @instantiation_params ||= InstantiationParamsType.new
        end

        def instantiate_vapp_template_params
          @instantiate_vapp_template_params ||= InstantiateVAppTemplateParamsType.new
        end

        def configure_networking(network)
          network_configuration.setParentNetwork(network.ref)
          network_configuration.setFenceMode(FenceModeValuesType.const_get('BRIDGED').value)

          vapp_network_configuration.setConfiguration(network_configuration)
          vapp_network_configuration.setNetworkName(network.ref.getName)

          network_config_section.setInfo(network_info)
          vAppNetworkConfigs = network_config_section.getNetworkConfig
          vAppNetworkConfigs.add(vapp_network_configuration)

          sections = instantiation_params.getSection
          sections.add(ObjectFactory.new.createNetworkConfigSection(network_config_section))
        end
      end
    end
  end
end
